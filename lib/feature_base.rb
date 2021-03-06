require "feature_base/version"
module FeatureBase

  def self.register(app, klass)
    app.config.tkml_features << klass
  end

  def self.inject_feature_record(name, class_name, description, dependencies = [])
    if can_inject?("features", "name", "class_name", "description", "dependencies")
      feature = Feature.find_or_initialize_by(class_name: class_name)
      feature.name = name
      feature.description = description

      dependencies.each do |dependency|
        # make sure dependency exists before adding it to dependencies
        dependency_feature = Feature.find_by(class_name: dependency)
        feature.dependencies << dependency_feature.class_name if dependency_feature && !feature.dependencies.include?(dependency_feature.class_name)
      end

      feature.save
    end
  end

  def self.inject_permission_records(klass, permissions)
    if can_inject?("features", "name", "class_name", "description", "dependencies") &&
        can_inject?("permissions", "can", "callback_name", "name")
      feature = Feature.find_by(class_name: klass.to_s)
      permissions.each do |p|
        permission = Permission.find_or_initialize_by(can: p[:can],
                                                      callback_name: p[:callback_name])
        permission.name = p[:name]
        unless permission.features.include?(feature)
          permission.features << feature
        end
        permission.save
      end
    end

  end

  def self.register_autoload_path(app, name)
    app.config.autoload_paths += [
      File.expand_path(
        "#{Rails.root}/features/#{name}/lib/#{name}.rb"
      )
    ]
  end

  private

  def self.can_inject?(table_name, *columns)
    array_of_booleans = []
    if ActiveRecord::Base.connection.tables.include?(table_name)
      array_of_booleans << ActiveRecord::Base.connection.tables.include?(table_name)
      columns.each do |column|
        array_of_booleans << ActiveRecord::Base.connection.column_exists?(table_name, column)
      end
    end
    !array_of_booleans.include?(false) && array_of_booleans.any?
  end
end
