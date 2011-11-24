<?xml version='1.0'?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:param name="filtrevalue"/>
<xsl:param name="filtresigle"/>
<xsl:param name="gofiltre"/>
<xsl:param name="sens"/>
<xsl:param name="rhm"/>

<xsl:template match="/">
  <xsl:for-each select="srfil/warning">
      <div class="warning">
        <p class="warnname"><xsl:value-of select="nom"/></p>
        <p class="warndesc"><xsl:value-of select="desc"/></p>
        <p class="warndetail"><xsl:value-of select="detail"/></p>
      </div>
  </xsl:for-each>
  <xsl:for-each select="srfil/msg">
     <div class="msg">
      <div class="msgbrut">
          <div class="msgbrutname"><xsl:value-of select="msgbrut/nom"/></div>
          <div class="msgbrutcontent">
            <xsl:for-each select="msgbrut/valeur/line">
              <p><xsl:value-of select="." /></p>
            </xsl:for-each>
          </div>
      </div>
      <div class="msgdecode">
        <xsl:for-each select="msgdecode/info">
          <div class="info">
            <div class="nom"><xsl:value-of select="nom"/></div>
            <div class="code"><xsl:value-of select="code"/></div>
            <div class="valeur"><xsl:value-of select="valeur"/></div>
            <div class="desc"><xsl:value-of select="desc"/></div>
            <div class="detail"><xsl:value-of select="detail"/></div>
          </div>
          <xsl:if test="listeml">
            <div class="info">
              <div class="nom">Liste des ML de la station</div>
                <div class="code">
                  <xsl:for-each select="listeml/info">
                    <p><xsl:value-of select="code"/></p>
                  </xsl:for-each>
                </div>
                <div class="valeur">
                  <xsl:for-each select="listeml/info">
                    <p><xsl:value-of select="valeur"/></p>
                  </xsl:for-each>
                </div>
                <div class="desc">
                  <xsl:for-each select="listeml/info">
                    <p><xsl:value-of select="desc"/></p>
                  </xsl:for-each>
                </div>
              </div>
          </xsl:if>
        </xsl:for-each>
      </div>
      <div class="infocomp">
        <xsl:for-each select="msgdecode/infocomp/info">
          <div class="info">
            <div class="nom"><xsl:value-of select="nom"/></div>
            <div class="code"><xsl:value-of select="code"/></div>
            <div class="valeur"><xsl:value-of select="valeur"/></div>
            <div class="desc"><xsl:value-of select="desc"/></div>
            <div class="detail"><xsl:value-of select="detail"/></div>
          </div>
          <xsl:for-each select="info">
            <div class="info">
              <div class="nom_indent"><xsl:value-of select="nom"/></div>
              <div class="code_indent"><xsl:value-of select="code"/></div>
              <div class="valeur_indent"><xsl:value-of select="valeur"/></div>
              <div class="desc_indent"><xsl:value-of select="desc"/></div>
              <div class="detail_indent"><xsl:value-of select="detail"/></div>
            </div>
          </xsl:for-each>
          <xsl:for-each select="ml/info">
            <div class="info">
              <div class="nom_indent"><xsl:value-of select="nom"/></div>
              <div class="code_indent"><xsl:value-of select="code"/></div>
              <div class="valeur_indent"><xsl:value-of select="valeur"/></div>
              <div class="desc_indent"><xsl:value-of select="desc"/></div>
              <div class="detail_indent"><xsl:value-of select="detail"/></div>
            </div>
          </xsl:for-each>
        </xsl:for-each>
      </div>
      <div class="infocomp">
        <xsl:for-each select="msgdecode/infocomp/infocomp">
          <div class="info">
            <div class="nom"><xsl:value-of select="nom"/></div>
            <div class="code"><xsl:value-of select="code"/></div>
            <div class="valeur"><xsl:value-of select="valeur"/></div>
            <div class="desc"><xsl:value-of select="desc"/></div>
            <div class="detail"><xsl:value-of select="detail"/></div>
          </div>
          <xsl:for-each select="info">
            <div class="info">
              <div class="nom_indent"><xsl:value-of select="nom"/></div>
              <div class="code_indent"><xsl:value-of select="code"/></div>
              <div class="valeur_indent"><xsl:value-of select="valeur"/></div>
              <div class="desc_indent"><xsl:value-of select="desc"/></div>
              <div class="detail_indent"><xsl:value-of select="detail"/></div>
            </div>
            <xsl:for-each select="info">
              <div class="info">
                <div class="nom_indent"><xsl:value-of select="nom"/></div>
                <div class="code_indent"><xsl:value-of select="code"/></div>
                <div class="valeur_indent"><xsl:value-of select="valeur"/></div>
                <div class="desc_indent"><xsl:value-of select="desc"/></div>
                <div class="detail_indent"><xsl:value-of select="detail"/></div>
              </div>
            </xsl:for-each>
          </xsl:for-each>
          
          
          
          
        </xsl:for-each>
      </div>
      
      <div class="infocomp">
        <xsl:for-each select="msgdecode/infocomp/infocomp/infosup">
          <div class="info">
            <div class="nom"><xsl:value-of select="nom"/></div>
            <div class="code"><xsl:value-of select="code"/></div>
            <div class="valeur"><xsl:value-of select="valeur"/></div>
            <div class="desc"><xsl:value-of select="desc"/></div>
            <div class="detail"><xsl:value-of select="detail"/></div>
          </div>
          <xsl:for-each select="info">
            <div class="info">
              <div class="nom_indent"><xsl:value-of select="nom"/></div>
              <div class="code_indent"><xsl:value-of select="code"/></div>
              <div class="valeur_indent"><xsl:value-of select="valeur"/></div>
              <div class="desc_indent"><xsl:value-of select="desc"/></div>
              <div class="detail_indent"><xsl:value-of select="detail"/></div>
            </div>
          </xsl:for-each>
        </xsl:for-each>
      </div>
      
    </div>
  </xsl:for-each>
</xsl:template>

</xsl:stylesheet>