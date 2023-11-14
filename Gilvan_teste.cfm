<cfoutput>
	<cfset auxdtprev = CreateDate(ano,mes,dia)>
	<cfset nCont = 0>
	<cfloop condition="nCont lte 9">
	   <cfset nCont = nCont + 1>
	   <cfset auxdtprev = DateAdd( "d", 1, auxdtprev)>
	   <cfset vDiaSem = DayOfWeek(auxdtprev)>
	   <cfif vDiaSem neq 1 and vDiaSem neq 7>
			<!--- verificar se Feriado Nacional --->
			<cfquery name="rsFeriado" datasource="#dsn_inspecao#">
				 SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #auxdtprev#
			</cfquery>
			<cfif rsFeriado.recordcount gt 0>
			   <cfset nCont = nCont - 1>
			</cfif>
		</cfif>
		<!--- Verifica se final de semana  --->
		<cfif vDiaSem eq 1 or vDiaSem eq 7>
			<cfset nCont = nCont - 1>
		</cfif>
	</cfloop>
auxdtprev: #auxdtprev# <br>
<cfloop index="index" list="207,233,630,306,517,600">
        <li>#index#</li>
</cfloop>


</cfoutput>


<!---
<!---<cfset dtnovoprazo = CreateDate(right(form.cbdata,4),mid(form.cbdata,4,2),left(form.cbdata,2))> --->
<cfset dtnovoprazo = '2023-11-11'> 
<cfoutput>
    <cfset nCont = 1>
    <cfloop condition="nCont lte 1">
        <cfset nCont = nCont + 1>
        <cfset vDiaSem = DayOfWeek(dtnovoprazo)>
        vDiaSem #vDiaSem#<br>
        <cfif vDiaSem neq 1 and vDiaSem neq 7>
            <!--- verificar se Feriado Nacional --->
            <cfquery name="rsFeriado" datasource="#snci.dsn#">
                SELECT Fer_Data FROM FeriadoNacional where Fer_Data = '#dtnovoprazo#'
            </cfquery>
            
            <cfif rsFeriado.recordcount gt 0>
            <cfset nCont = nCont - 1>
                <cfset dtnovoprazo = DateAdd( "d", 1, dtnovoprazo)>
                <cfset dtnovoprazo = lsdateformat(dtnovoprazo,"YYYY-MM-DD")>
            </cfif>
            dtnovoprazo:#dtnovoprazo#<br>
        </cfif>
        <!--- Verifica se final de semana  --->
        <cfif vDiaSem eq 1 or vDiaSem eq 7>
            <cfset nCont = nCont - 1>
            <cfset dtnovoprazo = DateAdd( "d", 1, dtnovoprazo)>
            <cfset dtnovoprazo = lsdateformat(dtnovoprazo,"YYYY-MM-DD")>
        </cfif>	
    </cfloop>	
    dtnovoprazo: #dtnovoprazo#
</cfoutput> 
--->

