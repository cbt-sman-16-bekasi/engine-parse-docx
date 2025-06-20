<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
                xmlns:mathml="http://www.w3.org/1998/Math/MathML"
                exclude-result-prefixes="m">

  <xsl:output method="xml" indent="yes"/>

  <!-- Root match -->
  <xsl:template match="/">
    <mathml:math xmlns:mathml="http://www.w3.org/1998/Math/MathML">
      <xsl:apply-templates/>
    </mathml:math>
  </xsl:template>

  <!-- Basic text (symbol, variable, number, etc.) -->
  <xsl:template match="m:t">
    <mathml:mi>
      <xsl:value-of select="."/>
    </mathml:mi>
  </xsl:template>

  <!-- Group of runs -->
  <xsl:template match="m:r">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Fraction -->
  <xsl:template match="m:f">
    <mathml:mfrac>
      <xsl:apply-templates select="m:num"/>
      <xsl:apply-templates select="m:den"/>
    </mathml:mfrac>
  </xsl:template>

  <!-- Superscript -->
  <xsl:template match="m:sup">
    <mathml:msup>
      <xsl:apply-templates select="m:e"/>
      <xsl:apply-templates select="m:sup"/>
    </mathml:msup>
  </xsl:template>

  <!-- Square root -->
  <xsl:template match="m:rad">
    <mathml:msqrt>
      <xsl:apply-templates select="m:deg"/>
      <xsl:apply-templates select="m:e"/>
    </mathml:msqrt>
  </xsl:template>

  <!-- Numerator / Denominator / Sup base -->
  <xsl:template match="m:num | m:den | m:e">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Superscript value -->
  <xsl:template match="m:sup/m:sup">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Row of expressions -->
  <xsl:template match="m:oMath">
    <mathml:mrow>
      <xsl:apply-templates/>
    </mathml:mrow>
  </xsl:template>

  <!-- Fallback: Ignore anything not handled -->
  <xsl:template match="text()"/>
  <xsl:template match="*">
    <xsl:apply-templates/>
  </xsl:template>

</xsl:stylesheet>
