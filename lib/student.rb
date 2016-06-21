require 'pry'

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :name,:grade
  attr_reader :id

  def initialize(name,grade)
    @name = name
    @grade = grade
    @id = nil
  end

  ATTRIBUTES = {
    id: "INTEGER PRIMARY KEY AUTOINCREMENT",
    name: "TEXT",
    grade: "TEXT"
  }

  def self.public_attributes
    ATTRIBUTES.keys.reject {|key| key == :id}
  end

  def values
    self.class.public_attributes.map do |key|
      self.send(key)
    end
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE students (
      id INTEGER PRIMARY KEY,
      name TEXT,
    grade TEXT)
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE students
    SQL
    DB[:conn].execute(sql)
  end

  def save
    persisted? ? update : insert
  end


  def persisted?
    !!self.id
  end


  def self.create(options)
  	student = Student.new(options[:name],options[:grade])
  	student.save
  	student
  end


  private

  # def update_string
  # 	binding.pry
  #   update_string = insert_string.split(", ").unshift(id:)
  #   update_string.map {|item| "#{item} = ?"}.join(", ")
  # end

  def insert_string
    self.class.public_attributes.map {|key| key.to_s}.join(", ")
  end

  def insert
    question_marks = (self.class.public_attributes.map {|key| "?"}.join(", "))
    sql = <<-SQL
    INSERT INTO students (#{insert_string}) VALUES (#{question_marks})
    SQL
    DB[:conn].execute(sql,*values)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students").flatten[0]
  end

  def update
    sql = <<-SQL
    UPDATE FROM students SET (#{update_string})
    WHERE id = ?
      SQL
    values.unshift(self.id)
    DB[:conn].execute(sql,*values)
  end
end
