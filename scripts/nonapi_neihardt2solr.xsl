<xsl:stylesheet version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
  <xsl:output indent="yes"/>
  <xsl:include href="../../../scripts/xslt/cdrh_to_solr/lib/common.xsl"/>
  <!-- 
         Fields:
  * = multivalued
  
    id
    title
    titleAlt
    author*
    dateNormalized
    dateSort
    dateDisplay
    category
    subcategory
    topic*
    keywords*
    people*
    places*
    text
  -->
  <xsl:template match="/">
    <add>
      <doc>
        <field name="id">
          <!-- Get the filename -->
          <xsl:variable name="filename" select="tokenize(base-uri(.), '/')[last()]"/>
          <!-- Split the filename using '\.' -->
          <xsl:variable name="filenamepart" select="substring-before($filename, '.xml')"/>
          <!-- Remove the file extension -->
          <xsl:value-of select="$filenamepart"/>
        </field>
        <field name="title">
          <xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title[@type='main']"/>
        </field>
        <!-- alternate title, used for display and sorting purposes -->
        <!--<field name="titleAlt"><xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl/title[@type='main']"/></field>-->
        <!-- ======================================
                       titleAlt (for sorting
          Multi=NO   "“‘  |The |A |
        ===========================================-->
        <field name="titleAlt">
          <xsl:call-template name="normalize_name">
            <xsl:with-param name="string">
              <xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title[@type='main']"/>
            </xsl:with-param>
          </xsl:call-template>
        </field>
        <xsl:for-each select="/TEI/teiHeader/fileDesc/titleStmt/author">
          <field name="author">
            <xsl:apply-templates/>
          </field>
        </xsl:for-each>
        <xsl:for-each select="/TEI/teiHeader/profileDesc/particDesc/person[@role='recipient']/persName[1]">
          <xsl:if test="normalize-space(.) != ''">
            <field name="recipient">
              <xsl:apply-templates/>
            </field>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/repository">
          <xsl:if test="normalize-space(.) != ''">
            <field name="repository">
              <xsl:apply-templates/>
            </field>
          </xsl:if>
        </xsl:for-each>
        <xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/bibl/title[@level='j'][normalize-space()]">
          <field name="publication">
            <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl/title[@level='j']"/>
          </field>
        </xsl:if>
        <field name="dateSort">
          <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl/date/@when"/>
        </field>
        <field name="dateNormalized">
          <xsl:call-template name="extractDate">
            <xsl:with-param name="date" select="/TEI/teiHeader/fileDesc/sourceDesc/bibl/date/@when"/>
          </xsl:call-template>
        </field>
        <field name="dateDisplay">
          <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl/date"/>
        </field>
        <field name="category">
          <xsl:value-of select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='category']/term"/>
        </field>
        <field name="subcategory">
          <xsl:value-of select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='subcategory']/term"/>
        </field>
        <xsl:for-each select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='topic']/term">
          <xsl:if test="normalize-space(.) != ''">
            <field name="topic">
              <xsl:apply-templates/>
            </field>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='keywords']/term">
          <xsl:if test="normalize-space(.) != ''">
            <field name="keywords">
              <xsl:apply-templates/>
            </field>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='people']/term">
          <xsl:if test="normalize-space(.) != ''">
            <field name="people">
              <xsl:apply-templates/>
            </field>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='places']/term">
          <xsl:if test="normalize-space(.) != ''">
            <field name="places">
              <xsl:apply-templates/>
            </field>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='works']/term">
          <xsl:if test="normalize-space(.) != ''">
            <field name="works">
              <xsl:apply-templates/>
            </field>
          </xsl:if>
        </xsl:for-each>
        <field name="text">
          <xsl:value-of select="//text"/>
        </field>
      </doc>
    </add>
  </xsl:template>
</xsl:stylesheet>
