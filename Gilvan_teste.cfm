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
<cfquery name="rsReinc" datasource="#dsn_inspecao#">
    SELECT Itn_Reincidentes
    FROM Itens_Verificacao
    WHERE (((Itn_Modalidade)='0') AND 
    ((Itn_Ano)='2024') AND 
    ((Itn_TipoUnidade)=4) AND 
    ((Itn_NumGrupo)=702) AND 
    ((Itn_NumItem)=2))
</cfquery>
<cfset grp=''>
<cfset itm=''>
<cfset grpitmsql=''>
<cfloop index="index" list="#rsReinc.Itn_Reincidentes#">
  <!---  #index#<br> --->
    <cfset grpitm = Replace(index,'_',',',"All")>
    <cfset grp = left(grpitm,find(",",grpitm)-1)>
    <cfset itm = mid(grpitm,(find(",",grpitm) + 1),len(grpitm))>
    <cfif grpitmsql eq ''>
        <cfset grpitmsql = "Pos_NumGrupo = " & #grp# & " and Pos_NumItem = " & #itm#>
    <cfelse>
        <cfset grpitmsql = #grpitmsql# & " or Pos_NumGrupo = " & #grp# & " and Pos_NumItem = " & #itm#>
    </cfif>
    <cfset grp=''>
    <cfset itm=''>
<!---    
    grp: #mid(grpitm,(find(",",grpitm) + 1),len(grpitm))#<br>
    itm: #right(grpitm,(find(",",grpitm) + 1))#<br> --->
    grpitmsql: #grpitmsql#<br>
</cfloop>
<!---
<cfset grp = trim(left(grp,(len(grp)-1)))>
<cfset itm = trim(left(itm,(len(itm)-1)))>

grp: #grp#<br>
itm: #itm#<br>
grpitmsql: #grpitmsql#<br>
--->
<cfquery name="rsReincb" datasource="#dsn_inspecao#">
		SELECT Pos_Inspecao, Pos_Unidade, Pos_NumGrupo, Pos_NumItem, Pos_Situacao_Resp, STO_Descricao
		FROM ParecerUnidade INNER JOIN Situacao_Ponto ON Pos_Situacao_Resp = STO_Codigo
		WHERE (Pos_Inspecao='3200102023' AND  Pos_Situacao_Resp In (1,6,7,17,22,2,4,5,8,20,15,16,18,19,23) and
        (#grpitmsql#)) 
		order by Pos_Inspecao 
</cfquery>
SELECT Pos_Inspecao, Pos_Unidade, Pos_NumGrupo, Pos_NumItem, Pos_Situacao_Resp, STO_Descricao
FROM ParecerUnidade INNER JOIN Situacao_Ponto ON Pos_Situacao_Resp = STO_Codigo
WHERE (Pos_Inspecao='3200102023' AND  Pos_Situacao_Resp In (1,6,7,17,22,2,4,5,8,20,15,16,18,19,23) and
(#grpitmsql#)) 
order by Pos_Inspecao 
<cfloop query="rsReincb">
 #Pos_Inspecao#, #Pos_Unidade#, #Pos_NumGrupo#, #Pos_NumItem#, #Pos_Situacao_Resp#<br>
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

