<cfcomponent displayname="Componente Usuário" hint="Cadastro dos Usuários do Aplicativo">
	<cffunction name="IncUsu" access="remote" output="Yes">
		<cfargument name="sfrmlogin" required="yes">
		<cfargument name="sfrmmatricula" required="yes">
    	<cfargument name="sfrmOrgao" required="yes">		
		<cfargument name="sfrmnome" required="yes">
		<cfargument name="sfrmsenha" required="yes">
		<cfargument name="sfrmemail" required="yes">
		<cfargument name="sfrmacesso" required="yes">					
		<cfargument name="sacao" required="yes">
				
      <cfif #Arguments.sacao# is "inc">
	     <cfquery datasource="DBConDoc">
		insert into Pessoal (Pes_Matricula, Pes_Nome, Pes_Org_Num, Pes_Login, Pes_Senha, Pes_email, Pes_Acesso) values (<cfqueryparam  cfsqltype="cf_sql_varchar" value="#Arguments.sfrmmatricula#">, <cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.sfrmnome#">, <cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.sfrmOrgao#">, <cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.sfrmlogin#">, <cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.sfrmsenha#">, <cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.sfrmemail#">, <cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.sfrmacesso#">) 
      </cfquery> 
      </cfif>	
      <cfif #Arguments.sacao# is "alt">
       <cfquery datasource="DBConDoc">
     UPDATE Pessoal SET Pes_Nome=<cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.sfrmnome#">, Pes_Org_Num=<cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.sfrmOrgao#">, Pes_Login=<cfqueryparam  cfsqltype="cf_sql_varchar" value="#Arguments.sfrmlogin#">, Pes_Senha=<cfqueryparam  cfsqltype="cf_sql_varchar" value="#Arguments.sfrmsenha#">, Pes_email=<cfqueryparam  cfsqltype="cf_sql_varchar" value="#Arguments.sfrmemail#">, Pes_Acesso=<cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.sfrmacesso#"> WHERE Pes_Matricula=<cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.sfrmmatricula#">
       </cfquery> 
      </cfif>
      <cfif #Arguments.sacao# is "exc">
	  <cfquery datasource="DBConDoc">
       UPDATE Pessoal SET Pes_Org_Num='32000133', Pes_Acesso='usu'  WHERE Pes_Matricula=<cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.sfrmmatricula#">
	   </cfquery>
      </cfif>
	  <cfif #Arguments.sacao# is "aju">
       <cfquery datasource="DBConDoc">
     UPDATE Pessoal SET Pes_Nome=<cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.sfrmnome#">, Pes_Senha=<cfqueryparam  cfsqltype="cf_sql_varchar" value="#Arguments.sfrmsenha#">, Pes_email=<cfqueryparam  cfsqltype="cf_sql_varchar" value="#Arguments.sfrmemail#"> WHERE Pes_Matricula=<cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.sfrmmatricula#">
       </cfquery> 
	   <cfoutput>
		  <cflocation url="../Numeracao.cfm"> 
	  </cfoutput>
      </cfif>
	   <cfif #Arguments.sacao# is "cad">
       <cfquery datasource="DBConDoc">
     UPDATE Pessoal SET Pes_Nome=<cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.sfrmnome#">, Pes_Senha=<cfqueryparam  cfsqltype="cf_sql_varchar" value="#Arguments.sfrmsenha#">, Pes_email=<cfqueryparam  cfsqltype="cf_sql_varchar" value="#Arguments.sfrmemail#"> WHERE Pes_Matricula=<cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.sfrmmatricula#">
       </cfquery> 
	   <cfoutput>
		  <cflocation url="../entrada.cfm"> 
	  </cfoutput>
      </cfif>
	  <cfoutput>
		  <cflocation url="../usuario.cfm"> 
	  </cfoutput>
	</cffunction>	
</cfcomponent>