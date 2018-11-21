class TeiToEs < XmlToEs

  def works
    works = get_list(@xpaths["works"]).map { |w| CommonXml.normalize_space(w) }
    works.uniq
  end

end
