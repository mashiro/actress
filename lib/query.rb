class QueryParser < Parslet::Parser
  rule(:space) { match('\s').repeat(1) }
  rule(:space?) { space.maybe }
  rule(:operator) { match('[<>]') }
  rule(:operator?) { operator.maybe }

  rule(:term) {
    match(%([^"':\s])).repeat(1)
  }

  rule(:phrase) {
    str(%(')) >> match(%([^'])).repeat(1) >> str(%(')) |
    str(%(")) >> match(%([^"])).repeat(1) >> str(%("))
  }

  rule(:value) {
    operator?.as(:operator) >> (term.as(:term) | phrase.as(:phrase)).as(:value)
  }

  rule(:key) {
    term
  }

  rule(:pair) {
    key.as(:key) >> str(':') >> value.as(:value)
  }

  rule(:token) {
    phrase.as(:phrase).as(:phrase_token) |
    pair.as(:pair).as(:pair_token) |
    term.as(:term).as(:term_token)
  }

  rule(:expressions) {
    (space? >> token >> (space >> token).repeat >> space?).repeat(0, 1).as(:expressions)
  }

  root(:expressions)
end

class QueryTransform < Parslet::Transform
  def apply(obj, context = nil)
    context ||= {}
    context[:encounters] ||= Encounter.arel_table
    context[:combatants] ||= Combatant.arel_table
    context[:encounter_values] ||= []
    context[:combatant_values] ||= []
    super
  end

  rule(term: simple(:term)) {
    term.to_s
  }

  rule(phrase: simple(:phrase)) {
    phrase.to_s.gsub(/(^["'])|(["']$)/, '"')
  }

  rule(pair: {key: simple(:key), value: {operator: simple(:operator), value: simple(:value)}}) {
    {key: key, value: {operator: operator, value: value}}
  }

  rule(term_token: simple(:text)) {
    encounter_values << Encounter.by_name(text.to_s)
    nil
  }

  rule(phrase_token: simple(:text)) {
    encounter_values << Encounter.by_name(text.to_s)
    nil
  }

  rule(pair_token: {key: simple(:key), value: {operator: simple(:operator), value: simple(:value)}}) {
    case key
    when /^ptdps$/i
      case operator
      when '>' then encounter_values << Encounter.where(encounters[:encdps].gt(value))
      when '<' then encounter_values << Encounter.where(encounters[:encdps].lt(value))
      end
    when /^(combatant|user|player)$/i
      combatant_values << Combatant.by_name(value)
    when /^job$/i
      combatant_values << Combatant.where(job: value)
    when /^dps$/i
      case operator
      when '>' then combatant_values << Combatant.where(combatants[:encdps].gt(value))
      when '<' then combatant_values << Combatant.where(combatants[:encdps].lt(value))
      end
    end

    nil
  }

  rule(expressions: sequence(:scopes)) {
    encounter_scope = encounter_values.reject(&:nil?).inject(scope, &:merge)
    combatant_scope = combatant_values.reject(&:nil?).inject(&:merge)

    scope = encounter_scope
    scope = scope.where(encid: combatant_scope.distinct.pluck('encid')) if combatant_scope
    scope
  }

  def merge
  end
end

module Query
  class << self
    def build(scope, str)
      parser = QueryParser.new
      tree = parser.parse str
      transform = QueryTransform.new
      transform.apply tree, scope: scope
    end
  end
end
