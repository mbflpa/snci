<cfcomponent displayname="Componente Feriado" hint="Cadastro dos Feriado Nacionais">
	<cffunction name="IncFer" access="remote" output="Yes">
		<cfargument name="sfrmdata" required="yes">
		<cfargument name="sfrmdesc" required="yes">
		<cfargument name="sacao" required="yes">

        <cfset dia=#left(Arguments.sfrmdata,2)#>
	    <cfset mes=#mid(Arguments.sfrmdata,4,2)#>
		<cfset ano=#right(Arguments.sfrmdata,4)#>						
     <!--- SELECT Fer_Data, Fer_Descricao FROM FeriadoNacional order by Fer_Data    createodbcdate(createdate(ano,mes,dia))---> 
	  <cfquery name="rsBuscar" datasource="DBSNCI">
	    SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #createodbcdate(createdate(ano,mes,dia))#
	  </cfquery>
	  
	  <cfif #Arguments.sacao# is "inc">
		  <cfif rsBuscar.recordcount eq 0>
			   <cfquery datasource="DBSNCI">
				insert into FeriadoNacional(Fer_Data, Fer_Descricao) values (
				#createodbcdate(createdate(ano,mes,dia))#
				,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.sfrmdesc#">
				) 
			   </cfquery> 
		  <cfelse>		   
			   <script language="javascript">
				  alert("Data já cadastrada!")
				  location.href = "../FeriadoNacional.cfm?flush=true" ; 
			   </script> 
		  </cfif>	
      </cfif>		  
	  <!--- SELECT Fer_Data, Fer_Descricao FROM FeriadoNacional order by Fer_Data ---> 
      <cfif #Arguments.sacao# is "alt" and rsBuscar.recordcount gt 0>
       <cfquery datasource="DBSNCI">
        UPDATE FeriadoNacional SET Fer_Descricao=
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.sfrmdesc#">
		WHERE Fer_Data = 
		#createodbcdate(createdate(ano,mes,dia))#
       </cfquery> 
      </cfif>

      <cfif #form.sacao# is "exc"  and rsBuscar.recordcount gt 0>
			 <cfquery datasource="DBSNCI">
				DELETE from FeriadoNacional WHERE Fer_Data = #createodbcdate(createdate(ano,mes,dia))#
			 </cfquery>
      </cfif>
   <cfoutput>
	  <cflocation url="../FeriadoNacional.cfm?flush=true"> 
   </cfoutput>
	</cffunction>	
</cfcomponent>