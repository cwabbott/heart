module KnowsTheDomain
  def configuration
    @configuration ||= Configuration.first
  end
end
World(KnowsTheDomain)