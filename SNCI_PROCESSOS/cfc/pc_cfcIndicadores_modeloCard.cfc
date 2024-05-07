<cfcomponent >
	<cfprocessingdirective pageencoding = "utf-8">	
	
	<cffunction name="criarCardIndicador" access="public" returntype="string" hint="cria os cards com as informações dos resultados dos indicadores">
    	<cfargument name="tipoDeCard" type="string" required="no" default="bg-info">
		<cfargument name="siglaIndicador" type="string" required="yes">
		<cfargument name="descricaoIndicador" type="string" required="yes">
        <cfargument name="percentualIndicadorFormatado" type="string" required="yes">
        <cfargument name="resultadoEmRelacaoMeta" type="string" required="yes">
		<cfargument name="resultadoEmRelacaoMetaFormatado" type="string" required="yes">
        <cfargument name="infoRodape" type="string" required="yes">
		<cfargument name="icone" type="string" required="no" default="fas fa-chart-line">

        <cfset var infoBox = "">
        
        <cfoutput>
            <cfsavecontent variable="infoBox">
                <div class="info-box #tipoDeCard#">
                    <div class="ribbon-wrapper ribbon-xl">
                        
                        <div class="ribbon" id="ribbon" data-value="#resultadoEmRelacaoMeta#"></div>
                       
                    </div>
                    <span class="info-box-icon"><i class="#icone#" style="font-size:45px"></i></span>

                    <div class="info-box-content">
                    
                        <span class="info-box-text"><font style="vertical-align: inherit;"><font style="vertical-align: inherit;font-size:22px">#siglaIndicador# = #percentualIndicadorFormatado#%</font></font></span><span style="font-size:12px;position:absolute; top:36px">#descricaoIndicador#</span>
                        
                        <cfif resultadoEmRelacaoMeta neq ''>    
                            <span class="info-box-number"><font style="vertical-align: inherit;"><font style="vertical-align: inherit;inherit;font-size:20px"><strong>#resultadoEmRelacaoMetaFormatado#%</strong></font></font><span style="font-size:10px;"> em relação a meta = (#siglaIndicador# &divide; Meta) x 100</span></span>
                        <cfelse>
                            <br>
                        </cfif>
                        <div class="progress" style="width:90%">
                            <div class="progress-bar" style="width: #resultadoEmRelacaoMeta#%"></div>
                        </div>
                        <span class="progress-description"><font style="vertical-align: inherit;"><font style="vertical-align: inherit;">
                            #infoRodape#
                        </font></font></span>
                    </div>
                </div>
            </cfsavecontent>
        </cfoutput>
        
        <cfreturn infoBox>
    </cffunction>

</cfcomponent>