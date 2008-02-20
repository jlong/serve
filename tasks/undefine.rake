def undefine_task(*names)
  app = Rake.application
  tasks = app.instance_variable_get('@tasks')
  names.flatten.each { |name| tasks.delete(name) }
end