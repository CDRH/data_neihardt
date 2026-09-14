<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0"
  exclude-result-prefixes="xsl tei xs">

  <!-- ==================================================================== -->
  <!--                             IMPORTS                                  -->
  <!-- ==================================================================== -->

  <xsl:import href="../.xslt-datura/tei_to_html/tei_to_html.xsl"/>

  <!-- To override, copy this file into your collection's script directory
    and change the above paths to:
    "../../.xslt-datura/tei_to_html/lib/formatting.xsl"
 -->

  <!-- For display in TEI framework, have changed all namespace declarations to http://www.tei-c.org/ns/1.0. If different (e.g. Whitman), will need to change -->
  <xsl:output method="xml" indent="no" encoding="UTF-8" omit-xml-declaration="yes"/>


  <!-- ==================================================================== -->
  <!--                           PARAMETERS                                 -->
  <!-- ==================================================================== -->

  <xsl:param name="collection"/>
  <xsl:param name="data_base"/>
  <xsl:param name="environment"/>
  <xsl:param name="image_large"/>
  <xsl:param name="image_thumb"/>
  <xsl:param name="image_illustration"/>
  <xsl:param name="media_base"/>
  <xsl:param name="site_url"/>
  
  <xsl:variable name="newline" select="'&#x0A;'"/>
  <xsl:variable name="title" select="//teiHeader//titleStmt//title[1]"/>
  <xsl:variable name="sender" select="//teiHeader//correspAction[@type='sentBy']/persName"/>
  <xsl:variable name="recipient" select="//teiHeader//correspAction[@type='deliveredTo']/persName"/>
  <xsl:variable name="category" select="//teiHeader//keywords[@n='category']/term[1]"/>
  <xsl:variable name="subcategory" select="//teiHeader//keywords[@n='subcategory']/term[1]"/>
  <xsl:variable name="date" select="//teiHeader//bibl/date/@when"/>
  <xsl:variable name="date_display" select="//teiHeader//bibl/date"/>
  <xsl:variable name="publication" select="//teiHeader//bibl/title[@level='j']"/>
  <xsl:variable name="repository" select="//teiHeader//msDesc//repository"/>
  <xsl:variable name="document" select="tokenize(base-uri(.),'/')[last()]"/>

  <!-- ==================================================================== -->
  <!--                            OVERRIDES                                 -->
  <!-- ==================================================================== -->
  
  <!-- Create front matter (YML) header -->
  <xsl:template match="/">
    <xsl:variable name="apos"><xsl:text>'</xsl:text></xsl:variable>
    <xsl:variable name="doubleQuote"><xsl:text>"</xsl:text></xsl:variable>
    <xsl:text>---</xsl:text>
    <xsl:value-of select="$newline"/>
    <xsl:text>title: </xsl:text><xsl:value-of select="normalize-space(replace(replace(replace($title,'\[','('),'\]',')'),':',' |'))"/>
    <xsl:value-of select="$newline"/>
    <xsl:text>document: </xsl:text><xsl:value-of select="$document"/>
    <xsl:value-of select="$newline"/>
    <!-- author differs between correspondence and essays/reviews -->
    <!-- author should be an array because there could be multiple values -->
    <xsl:text>author: [</xsl:text>
   <xsl:choose>
     <xsl:when test="$category = 'Correspondence'"> 
       <xsl:for-each select="//teiHeader//correspAction[@type='sentBy']/persName">
         <xsl:variable name="authorName" select="."/>
         <xsl:variable name="count" select="count(following::persName[parent::correspAction[@type='sentBy']])"/>
        <xsl:text>"</xsl:text><xsl:value-of select="$authorName"/><xsl:text>"</xsl:text>
          <xsl:if test="$count != 0"><xsl:text>,</xsl:text></xsl:if>
      </xsl:for-each>
     </xsl:when>
     <!-- check this: no author listed for essays/reviews -->
   <xsl:otherwise>
     "Neihardt, John Gneisenau, 1881-1973"
   </xsl:otherwise>
   </xsl:choose>
    <xsl:text>]</xsl:text>
    <xsl:value-of select="$newline"/>
    <!-- recipient should be an array because there could be multiple values -->
    <xsl:if test="$category = 'Correspondence'">
      <xsl:text>recipient: [</xsl:text>
      <!-- this info is duplicated in particDesc below -->
      <!--<xsl:for-each select="//teiHeader//correspAction[@type='deliveredTo']/persName">
        <xsl:variable name="recipName" select="normalize-space(.)"/>
        <xsl:variable name="count" select="count(following::persName[parent::correspAction[@type='deliveredTo']])"/>
        <xsl:if test="$recipName != ''">
          <xsl:text>"</xsl:text><xsl:value-of select="replace($recipName,$doubleQuote,$apos)"/><xsl:text>"</xsl:text>
          <xsl:if test="$count != 0"><xsl:text>,</xsl:text></xsl:if>
        </xsl:if>
      </xsl:for-each>-->
      <xsl:for-each select="//teiHeader//particDesc//person[@role='recipient']/persName">
        <!--<xsl:choose>
          <xsl:when test="preceding::persName = ."/>
          <xsl:otherwise>-->
            <xsl:variable name="recipName" select="normalize-space(.)"/>
        <xsl:variable name="count" select="count(following::persName[parent::person[@role='recipient']][string-length(text()) > 0])"/>
            <xsl:if test="$recipName != ''">
              <xsl:text>"</xsl:text><xsl:value-of select="replace($recipName,$doubleQuote,$apos)"/><xsl:text>"</xsl:text>
              <xsl:if test="$count != 0"><xsl:text>,</xsl:text></xsl:if>
            </xsl:if>
          <!--</xsl:otherwise>
        </xsl:choose>-->
      </xsl:for-each>
      <xsl:text>]</xsl:text>
      <xsl:value-of select="$newline"/>
    </xsl:if>
    <xsl:text>date: </xsl:text><xsl:value-of select="$date"/>
    <xsl:value-of select="$newline"/>
    <xsl:text>publication: </xsl:text><xsl:value-of select="$publication"/>
    <xsl:value-of select="$newline"/>
    <xsl:text>category: </xsl:text><xsl:value-of select="$category"/>
    <xsl:value-of select="$newline"/>
    <xsl:text>subcategory: </xsl:text><xsl:value-of select="$subcategory"/>
    <xsl:value-of select="$newline"/>
    <!-- places should be an array because there could be multiple values -->
    <xsl:text>places: [</xsl:text>
    <xsl:for-each select="//teiHeader//keywords[@n='places']/term">
      <xsl:variable name="placeName" select="."/>
      <xsl:variable name="count" select="count(following-sibling::term[string-length(text()) > 0])"/>
         <xsl:if test="$placeName != '' and $placeName != ' '">
           <xsl:text>"</xsl:text><xsl:value-of select="$placeName"/><xsl:text>"</xsl:text>
          <xsl:if test="$count != 0"><xsl:text>,</xsl:text></xsl:if>
         </xsl:if>
    </xsl:for-each>
    <xsl:text>]</xsl:text>
    <xsl:value-of select="$newline"/>
    <xsl:text>works: [</xsl:text>
    <xsl:for-each select="//teiHeader//keywords[@n='works']/term">
      <xsl:variable name="work" select="."/>
      <xsl:variable name="count" select="count(following-sibling::term)"/>
      <xsl:if test="$work != ''">
        <xsl:text>"</xsl:text><xsl:value-of select="replace($work,$doubleQuote,$apos)"/><xsl:text>"</xsl:text>
        <xsl:if test="$count != 0"><xsl:text>,</xsl:text></xsl:if>
      </xsl:if>
    </xsl:for-each><xsl:text>]</xsl:text>
    <xsl:value-of select="$newline"/>
    <xsl:text>keywords: [</xsl:text>
    <xsl:for-each select="//teiHeader//keywords[@n='keywords']/term">
      <xsl:variable name="keyword" select="."/>
      <xsl:variable name="count" select="count(following-sibling::term)"/>
      <xsl:if test="$keyword != ''">
        <xsl:text>"</xsl:text><xsl:value-of select="replace($keyword,$doubleQuote,$apos)"/><xsl:text>"</xsl:text>
        <xsl:if test="$count != 0"><xsl:text>,</xsl:text></xsl:if>
      </xsl:if>
    </xsl:for-each><xsl:text>]</xsl:text>
    <xsl:value-of select="$newline"/>
    <xsl:text>repository: [</xsl:text><xsl:if test="$repository != ''">"<xsl:value-of select="$repository"/>"</xsl:if>]
    <xsl:value-of select="$newline"/>
    <xsl:text>---</xsl:text>
    <xsl:value-of select="$newline"/>
    <xsl:value-of select="$newline"/>
    <h1 class="pagefind" data-pagefind-meta="title"><xsl:value-of select="$title"/></h1>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="text">
    <div id="main_div" class="main_div">
      <xsl:if test="$category != 'Life'">
      <div class="metadata">
        <ul>
          <li><strong><xsl:text>Title: </xsl:text></strong> <xsl:value-of select="$title"/></li>
          <xsl:if test="$category = 'Essays and Reviews'"> 
            <li><strong>Publication: </strong> <xsl:value-of select="$publication"/></li>
          </xsl:if>
          <xsl:if test="$date_display != '' or $date !=''">
            <li><strong>Date: </strong> <xsl:choose>
              <xsl:when test="$date_display != ''"><xsl:value-of select="$date_display"/></xsl:when>
              <xsl:otherwise><xsl:value-of select="$date"/></xsl:otherwise>
            </xsl:choose></li>
          </xsl:if>
          <!-- no author listed for essays/reviews -->
          <xsl:if test="$category = 'Correspondence'"> 
            <li><strong>Author(s): </strong> 
                <xsl:for-each select="//teiHeader//correspAction[@type='sentBy']/persName">
                  <xsl:variable name="authorName" select="."/>
                  <xsl:variable name="count" select="count(following-sibling::persName)"/>
                  <xsl:value-of select="$authorName"/><xsl:if test="$count != 0"><xsl:text>,</xsl:text></xsl:if>
                </xsl:for-each>
            </li>
          </xsl:if>
          <xsl:if test="//teiHeader//correspAction[@type='deliveredTo']/persName or //teiHeader//correspAction[@type='deliveredTo']/orgName">
            <li><strong>Recipient: </strong> 
              <!--<xsl:for-each select="//teiHeader//correspAction[@type='deliveredTo']/persName">
                <xsl:variable name="recipName" select="normalize-space(.)"/>
                <xsl:variable name="count" select="count(following::persName[parent::correspAction[@type='deliveredTo']])"/>
                <xsl:if test="$recipName != ''">
                  <xsl:value-of select="."/><xsl:if test="$count != 0"><xsl:text>,</xsl:text></xsl:if>
                </xsl:if>
              </xsl:for-each>-->
              <xsl:for-each select="//teiHeader//particDesc//person[@role='recipient']/persName">
                <xsl:variable name="recipName" select="normalize-space(.)"/>
                <xsl:variable name="count" select="count(following::persName[parent::person[@role='recipient']][string-length(text()) > 0])"/>
                <xsl:if test="$recipName != ''">
                  <xsl:value-of select="."/>
                  <xsl:if test="$count != 0"><xsl:text>, </xsl:text></xsl:if>
                </xsl:if>
              </xsl:for-each>
            </li>
          </xsl:if>
          <li><strong>TEI XML: </strong> <a href="{$document}"><xsl:value-of select="$document"/></a></li>
        </ul>
      </div>
      </xsl:if>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <xsl:template match="note[@type='curatorial'] | fw | pb"/>
  
  <xsl:template match="address/addrLine">
    <span class="tei_addrLine"><xsl:apply-templates/></span>
  </xsl:template>
  
  <xsl:template match="del[not(node())]"/>
  
  <xsl:template match="figure">
    <span class="tei_figure"><xsl:apply-templates/></span>
  </xsl:template>
  
  <xsl:template match="unclear">
    [<span class="tei_unclear"><xsl:apply-templates/></span>?]
  </xsl:template>
  
  <!-- override personography template -->
  <xsl:template name="person_info">
    <!-- oh dear, sorry about this, had to slugify -->
    <xsl:variable name="person_slug"><xsl:value-of select="lower-case(replace(replace(replace(replace(replace(persName[@type='display'],' ','-'),',',''),'\.',''),'\)',''),'\(',''))"/></xsl:variable>
    <div>
      <xsl:attribute name="class">
        <xsl:text>life_item</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="id">
        <xsl:value-of select="@xml:id"/>
      </xsl:attribute>
      <h3>
        <a>
          <xsl:attribute name="class">persNameLink</xsl:attribute>
          <xsl:attribute name="href"><xsl:value-of select="$site_url"/>../browse/recipients.html#<xsl:value-of select="$person_slug"/></xsl:attribute>
          <xsl:value-of select="persName[@type='display']"/>
        </a>
      </h3>
      <p><xsl:apply-templates select="note"/></p>
    </div>
  </xsl:template>
  
  <!-- add subhead template -->
  <xsl:template match="head[@type='sub']">
    <h4><xsl:apply-templates/></h4>
  </xsl:template>
  
</xsl:stylesheet>
