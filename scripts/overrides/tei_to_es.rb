class TeiToEs < XmlToEs

  def works
    works = get_list(@xpaths["works"]).map { |w| CommonXml.squeeze(w) }
    works.uniq
  end

end
