ActiveRecord::Base.default_timezone = :local

module Paginatable
  extend ActiveSupport::Concern

  module Extension
    attr_accessor :next_page, :prev_page
  end

  module ClassMethods
    def paginate(page, per)
      resources = self.offset((page - 1) * per).limit(per)
      resources.extend Extension
      resources.next_page = (resources.count < per) ? nil : page + 1
      resources.prev_page = ((page - 1) < 1) ? nil : page - 1
      resources
    end
  end
end

module FullText
  extend ActiveSupport::Concern

  included do
    scope :fulltext , -> (columns, query) {
      where(%(MATCH(#{Array(columns).join(',')}) AGAINST(? IN BOOLEAN MODE)), sanitize_conditions(query))
    }
  end
end

class Encounter < ActiveRecord::Base
  self.table_name = :encounter_table
  self.primary_key = :encid

  include Paginatable
  include FullText

  has_many :combatants, foreign_key: :encid, dependent: :delete_all
  has_many :damage_types, foreign_key: :encid, dependent: :delete_all
  has_many :attack_types, foreign_key: :encid, dependent: :delete_all
  has_many :swings, foreign_key: :encid, dependent: :delete_all

  scope :by_name, ->(name) { fulltext(['title', 'zone'], name) }

  class << self
    def latest
      order(starttime: :desc).first
    end
  end
end

class Combatant < ActiveRecord::Base
  self.table_name = :combatant_table
  self.primary_key = :encid, :name

  include Paginatable
  include FullText

  belongs_to :encounter, foreign_key: :encid
  has_many :damage_types, foreign_key: [:encid, :combatant]
  has_many :attack_types, foreign_key: [:encid, :attacker]
  has_many :swings, foreign_key: [:encid, :attacker]

  scope :by_name, ->(name) { fulltext(['name'], name) }
  scope :friendly, ->() { where(ally: 'T') }
  scope :enemy, ->() { where(ally: 'F') }

  def serializable_hash(options = {})
    super options.reverse_merge({
      except: [:swings]
    })
  end
end

class DamageType < ActiveRecord::Base
  self.table_name = :damagetype_table
  self.primary_key = :encid, :combatant
  self.inheritance_column = nil

  belongs_to :encounter, foreign_key: :encid
end

class AttackType < ActiveRecord::Base
  self.table_name = :attacktype_table
  self.inheritance_column = nil

  belongs_to :encounter, foreign_key: :encid
end

class Swing < ActiveRecord::Base
  self.table_name = :swing_table

  belongs_to :encounter, foreign_key: :encid
end

