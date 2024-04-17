<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:nomisma="http://nomisma.org/"
    exclude-result-prefixes="xs" version="2.0">

    <!-- XSLT templates for rendering the the query JSON from the OpenRefine reconciliation service into a valid Solr query -->
    <xsl:template match="/*[@type='object']">
        <xsl:variable name="query">
            <xsl:apply-templates select="query"/>
            <xsl:apply-templates select="type"/>
            <xsl:apply-templates select="properties"/>
        </xsl:variable>
        
        <xsl:text>q=</xsl:text>
        <xsl:value-of select="encode-for-uri($query)"/>       
        
        <!-- construct limit -->
        <xsl:text>&amp;rows=</xsl:text>
        <xsl:choose>
            <xsl:when test="limit castable as xs:integer">
                <xsl:value-of select="limit"/>
            </xsl:when>
            <xsl:otherwise>20</xsl:otherwise>
        </xsl:choose>
        
        <!-- include fl for score -->
        <xsl:text>&amp;fl=id,prefLabel,type,score</xsl:text>
        
        <!-- if the name is not 'json', then this is an aggregate query, so add qid parameter -->
        <xsl:if test="not(local-name() = 'json')">
            <xsl:text>&amp;qid=</xsl:text>
            <xsl:value-of select="local-name()"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="query">
        <xsl:variable name="frag" select="replace(., '/', '')"/>
        
        <xsl:text>(text:(</xsl:text>
        <xsl:value-of select="$frag"/>
        <xsl:text>) OR label:(</xsl:text>
        <xsl:value-of select="$frag"/>
        <xsl:text>)^5)</xsl:text>
    </xsl:template>
    
    <xsl:template match="properties">
        <xsl:apply-templates select="_" mode="prop"/>
    </xsl:template>
    
    <!-- try http://localhost:8080/orbeon/nomisma/apis/reconcile/?query={%22query%22:%22rome%22,%22properties%22:[{%22p%22:%22id%22,%22v%22:%22rome%22}]} -->
    
    <xsl:template match="_" mode="prop">
        <xsl:text> AND </xsl:text>
        <xsl:choose>
            <xsl:when test="(pid or p) and v">
                <xsl:choose>
                    <xsl:when test="pid">
                        <xsl:value-of select="pid"/>
                    </xsl:when>
                    <xsl:when test="p">
                        <xsl:value-of select="p"/>
                    </xsl:when>
                </xsl:choose>
                <xsl:text>:</xsl:text>
                <xsl:choose>
                    <xsl:when test="contains(pid, 'facet')">
                        <xsl:value-of select="concat('&#x022;', v, '&#x022;')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="v"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="name()"/>
                <xsl:text>:</xsl:text>
                <xsl:choose>
                    <xsl:when test="contains(name(), 'facet')">
                        <xsl:value-of select="concat('&#x022;', ., '&#x022;')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="type">
        <xsl:variable name="operator" select="if (parent::node()/type_strict = 'all') then 'AND' else 'OR'"/>
        
        <xsl:text> AND type:</xsl:text>
        <xsl:choose>
            <xsl:when test="@type='array'">
                <xsl:text>(</xsl:text>
                <xsl:apply-templates select="_">
                    <xsl:with-param name="operator" select="$operator"/>
                </xsl:apply-templates>
                <xsl:text>)</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat('&#x022;', ., '&#x022;')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="_">
        <xsl:param name="operator"/>
        
        <xsl:value-of select="concat('&#x022;', ., '&#x022;')"/>
        <xsl:if test="not(position() = last())">
            <xsl:value-of select="concat(' ', $operator, ' ')"/>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
