<cfcomponent displayname="Componente Usuário" hint="Calculo de gravidade">
	<cffunction name="Grav" access="remote" output="Yes">
		<cfargument name="funid" required="yes">
		<cfargument name="fninsp" required="yes">
    	<cfargument name="fngrup" required="yes">		
		<cfargument name="fnitem" required="yes">
		<cfargument name="cbox01" required="yes">
		<cfargument name="cbox02" required="yes">		
		<cfargument name="cbox03" required="yes">		
		<cfargument name="cbox04" required="yes">				
		<cfargument name="cbox05" required="yes">		
		<cfargument name="cbox06" required="yes">		
		<cfargument name="cbox07" required="yes">			
		<cfargument name="cbox08" required="yes">	
		<cfargument name="sacao" required="yes">											
	    <cfquery datasource="#dsn_inspecao#">
		insert into Pro_Analise (ProAna_Num_Insp, ProAna_Num_STO, ProAna_Num_Grupo, ProAna_Num_Item, ProAna_Col01, ProAna_Col02, ProAna_Col03, ProAna_Col04, ProAna_Col05, ProAna_Col06, ProAna_Col07, ProAna_Col08) values (<cfqueryparam  cfsqltype="cf_sql_varchar" value="#Arguments.fninsp#">, <cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.funid#">, <cfqueryparam cfsqltype="cf_sql_numeric" value="#Arguments.fngrup#">, <cfqueryparam cfsqltype="cf_sql_numeric" value="#Arguments.fnitem#">, <cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.cbox01#">, <cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.cbox02#">, <cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.cbox03#">, <cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.cbox04#">, <cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.cbox05#">, <cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.cbox06#">, <cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.cbox07#">, <cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.cbox08#">) 
	    </cfquery> 	
		<cflocation url="gfdtd.cfm">
	</cffunction>	
</cfcomponent>