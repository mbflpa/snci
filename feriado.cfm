
<!--- retorna o próximo dia útil --->
<cffunction name="diaUtil" returntype="date">
  <cfargument name="dt1" type="date" required="yes">  <!--- data inicial --->
  <cfargument name="qt" type="numeric" required="yes"> <!--- quantidade de dias --->

  <cfset feriados = ''>
  <!---<cfset feriados = listappend(feriados,Createdate(year(now()),4,21))>
  <cfset feriados = listappend(feriados,Createdate(year(now()),4,21))>
  <cfset feriados = listappend(feriados,Createdate(year(now()),5,1))>
  <cfset feriados = listappend(feriados,Createdate(year(now()),9,7))>
  <cfset feriados = listappend(feriados,Createdate(year(now()),10,12))> --->

<cfquery datasource="DBLT" name="qFeriados">
  SELECT DATA FROM FERIADOS WHERE DATA >= NOW();
</cfquery>

<!--- Armazenando os feriados em uma lista --->
<cfoutput query="qFeriados">
  <cfset feriados = listappend(feriados,Createdate(Year(DATA),Month(DATA),Day(DATA)))>
</cfoutput>
  <!--- <cfdump var="#qFeriados#"><br><br> <cfabort> --->

<cfset x = dateadd('d',0,dt1)>

 <cfloop from="1" to="#qt#" index="i">
	<cfswitch expression="#DayOfWeek(x)#">
	  <cfcase value="1" delimiters=";">
	    <cfset x = dateadd('d',1,x)>
	    <cfif listfind(feriados,x)>
		    <cfset x = dateadd('d',1,x)>
		</cfif>
	  </cfcase>
	  <cfcase value="6">
	    <cfset x = dateadd('d',3,x)>
	  </cfcase>
	  <cfcase value="7">
	    <cfset x = dateadd('d',2,x)>
	  </cfcase>
	  <cfcase value="2;3;4;5" delimiters=";">
	    <cfset x = dateadd('d',1,x)>
	    <cfif listfind(feriados,x)>
		    <cfset x = dateadd('d',1,x)>
		</cfif>
	  </cfcase>

	</cfswitch>
  </cfloop>
  <cfreturn x>
</cffunction>

<cfset dia = Createdate(2018,12,19)>
<cfoutput>#diaUtil(dia,10)#</cfoutput><br><br>