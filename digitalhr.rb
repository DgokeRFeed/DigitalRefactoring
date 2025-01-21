class User < ApplicationRecord
  # Исправил связи на 'has_and_belongs_to_many',
  # поскольку связи между сущностями 'many-to-many',
  # а взаимодействовать с промежуточной моделью нам не надо

  has_and_belongs_to_many :interests
  has_and_belongs_to_many :skills
end

class Interest < ApplicationRecord
  has_and_belongs_to_many :users
end

class Skill < ApplicationRecord
  has_and_belongs_to_many :users
end

odule Users
  class Create < ActiveInteraction::Base
    string :name, :surname, :patronymic, :email,
      :nationality, :country, :gender, :skills
    integer :age
    array :interests

    # вместо guard clause лучше использовать валидаторы
    validates(
      :name,
      :surname,
      :patronymic,
      :email,
      :age,
      :gender,
      :country,
      :nationality,
      :interests,
      :skills,
      presence: true
    )

    validates :email, uniqueness: true
    validates :gender, inclusion: { in: %w[male female] }
    validates :age, comparison: { greater_than: 0, less_than_or_equal_to: 90 }

    def execute
      # вместо интерполяции использовал join(' ')
      full_name = [surname, name, patronymic].join(' ')

      user_params = {
        name:,
        surname:,
        patronymic:,
        full_name:,
        email:,
        age:,
        gender:,
        country:,
        nationality:
      }

      # вместо create использовал new, чтобы не создавать объект в базе сразу
      user = User.new(user_params)

      # добавляя по одному объекту interest будет N+1
      user.interests = Interest.where(name: interests)

      # Skil.find(name: skil) внутри массива даст N+1
      user_skills = skills.split(',')
      user.skills = Skill.where(name: user_skills)

      # если объект не валиден, отдаем ошибки
      unless user.save
        errors.merge!(user.errors)
      end

      user
    end
  end
end

# 2. Иправление опечатки Skil
#
# Вариант 1: использовать rename_table
#
# def change
#   rename_table :skils, :skills
# end
#
# Вариант 2: создать новую таблицу, перенести данные, удалить старую таблицу
#
# def up
#   create_table :skills do |t|
#     t.name :string, null: false
#   end
#
#   execute 'INSERT INTO skills SELECT * FROM :skils'
# end
#
# удалить старую таблицу лучше потом, удостоверившись, что данные перенесены

##################################################
