class Dog
    attr_accessor :name, :breed, :id
 
     def initialize (id: nil, name: name, breed: breed)
        @id = id
        @name = name
        @breed = breed
     end
 
     def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
        SQL

        DB[:conn].execute(sql)
     end

     def self.drop_table
        sql = "DROP TABLE dogs;"
        DB[:conn].execute(sql)
    end

    def self.create(hash)
        dog = Dog.new
        #hash.each do |k, v|
        #    dog.send("#{k}=", v)
        #end
        dog.name = hash[:name]
        dog.breed = hash[:breed]
        dog.save
        dog
    end

    def self.new_from_db(row)
        dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?;"
        dog = Dog.new_from_db(DB[:conn].execute(sql, id)[0])
        dog
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
                INSERT INTO dogs (name, breed) VALUES (?, ?);
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
        end
        self
    end

    def update
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.find_or_create_by(name: name, breed: breed)
        matching_dogs = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?;", name, breed)
        if matching_dogs.empty?
            dog = self.create(name: name, breed: breed)
        else
            dog = self.new_from_db(matching_dogs[0])
        end
        dog
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?;"
        dog = Dog.new_from_db(DB[:conn].execute(sql, name)[0])
    end

 end