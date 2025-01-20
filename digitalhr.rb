class User < ApplicationRecord
  has_and_belongs_to_many :interests
  has_and_belongs_to_many :skills
end

class Interest < ApplicationRecord
  has_and_belongs_to_many :users
end

class Skill < ApplicationRecord
  has_and_belongs_to_many :users
end

module Users
  class Create < ActiveInteraction::Base
    hash :params do
      string :name, :patronymic, :email,
        :nationality, :country, :gender, :skills

      integer :age

      array :interests

      validates(
        :name,
        :patronymic,
        :email,
        :nationality,
        :country,
        :gender,
        :age,
        presence: true
      )

      validates :age, compartion: { greater_than: 0, less_than_or_equal_to: 90 }
      validates :gender, inclusion: { in: %w[male female] }
    end

    def execute
      return if User.where(email: params['email'])

      full_name =
        [
          params['surname'],
          params['name'],
          params['patronymic']
        ]
        .map!(&:capitalize)
        .join(' ')

      user_params = params.except(:interests, :skills).merge(full_name:)
      user = User.new(user_params)

      user.interests = Interest.where(name: params['interests'])

      user_skills = params['skills'].split(',')
      user.skills = Skill.where(name: user_skills)

      unless user.save
        errors.merge!(user.errors)
      end

      user
    end
  end
end

##################################################

class User < ApplicationRecord
  has_many :interests
  has_many :skills, class_name: 'Skil'
end

class Interest < ApplicationRecord
  has_many :users
end

class Skil < ApplicationRecord
  has_many :users
end

class Users::Create < ActiveInteraction::Base
  hash :params

  def execute
    #don't do anything if params is empty
    return unless params['name']
    return unless params['patronymic']
    return unless params['email']
    return unless params['age']
    return unless params['nationality']
    return unless params['country']
    return unless params['gender']
    ##########
    return if User.where(email: params['email'])
    return if params['age'] <= 0 || params['age'] > 90
    return if params['gender'] != 'male' or params['gender'] != female

    user_full_name = "#{params['surname']} #{params['name']} #{params['patronymic']}"
    user_params = params.except(:interests)
    user = User.create(user_params.merge(user_full_name))

    Intereset.where(name: params['interests']).each do |interest|
      user.interests = user.interest + interest
      user.save!
    end

    user_skills = []
    params['skills'].split(',').each do |skil|
      skil = Skil.find(name: skil)
      user_skills =  user_skills + [skil]
    end
    user.skills = user_skills
    user.save
  end
end

# Нужно:
# 1. Использовать gem ActiveInteraction => https://github.com/AaronLasseigne/active_interaction отрефакторить класс Users::Create
# 2. Исправить опечатку Skil. Есть 2 пути решения. Описать оба.
# 3. Исправить связи
# 4. Поднять Rails приложение и в нем использовать класс Users::Create
# 5. Написать тесты
# 6. При рефакторнге кода использовать Декларативное описание(подход в программировании)
