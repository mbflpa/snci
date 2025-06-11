<cfoutput>
    <!--- <cfdump var="#form#"> <cfdump var="#session#"> --->
    <!---  <cfdump var="#url#">  --->
</cfoutput>
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
    SELECT Usu_GrupoAcesso,Usu_Coordena,Usu_Matricula
    FROM Usuarios
    WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<cfset grpacesso = ucase(trim(qAcesso.Usu_GrupoAcesso))>
<!--- Excluir arquivos anteriores ao dia atual --->
<cfset sdata = dateformat(now(),"YYYYMMDDHH")>
<cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>
<cfset slocal = #diretorio# & 'Fechamento\'>

<cfquery name="rsRevisor" datasource="#dsn_inspecao#">
    SELECT 
        INP_Unidade,INP_Responsavel,INP_Modalidade,INP_NumInspecao, Und_Descricao, format(INP_DTConcluir_Despesas,'dd-MM-yyyy HH:mm:ss') as inpdtconcluirdespesas, Usu_Apelido, INP_ValorPrevisto, INP_AdiNoturno, INP_Deslocamento, INP_Diarias, INP_PassagemArea, INP_ReembVeicProprio, INP_RepousoRemunerado, INP_RessarcirEmpregado, INP_Outros
        FROM Inspecao INNER JOIN Unidades ON INP_Unidade = Und_Codigo 
        INNER JOIN Usuarios ON INP_LoginGestor_Despesas = Usu_Login
        WHERE INP_DTConcluir_Despesas between '#dtinic#' and '#dtfinal#' and INP_DTConcluir_Despesas is not null
        AND Right(INP_NumInspecao,4)='#ano#' 
        <cfif codse neq 't'>
            and Und_CodDiretoria = '#codse#'
        </cfif>
        <cfif codse eq 't' and numaval eq 't' and grpacesso eq 'GESTORES'>
            and Und_CodDiretoria in (#qAcesso.Usu_Coordena#)
        </cfif>
        <cfif numaval neq 't'>
            and INP_NumInspecao = '#numaval#'
        </cfif>
        ORDER BY Und_CodDiretoria, INP_NumInspecao
</cfquery>

<cfset sarquivo = #DateFormat(now(),"YYYYMMDDHH")# & '_' & #trim(qAcesso.Usu_Matricula)# & '.xls'>

<cfdirectory name="qList" filter="*.*" sort="name desc" directory="#slocal#">
  	<cfloop query="qList">
		   <cfif len(name) eq 23>
				<cfif (left(name,8) lt left(sdata,8)) or (int(mid(sdata,9,2) - mid(name,9,2)) gte 2)>
				    <cffile action="delete" file="#slocal##name#"> 
				</cfif>
		  </cfif>
	</cfloop>
<!---    
<cftry>

<cfif Month(Now()) eq 1>
  <cfset vANO = Year(Now()) - 1>
<cfelse>
  <cfset vANO = Year(Now())>
</cfif>

<cfset objPOI = CreateObject(
    "component",
    "Excel"
    ).Init()
    />

<cfset data = now() - 1>
	 <cfset objPOI.WriteSingleExcel(
    FilePath = ExpandPath( "./Fechamento/" & #sarquivo# ),
    Query = qAcesso,
	ColumnList = "a,b,c",
	ColumnNames = "Usu_GrupoAcesso,Usu_Coordena,Usu_Matricula",
	SheetName = "Despesas_avaliacao"
    ) />

<cfcatch type="any">
	<cfdump var="#cfcatch#">
</cfcatch>
</cftry> 
--->
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="public/bootstrap/bootstrap.min.css">
    <style>
        .quebra {
            background:#eceaea;
        } 
    </style>
</head>

<body style="background:#fff"> 

 <cfinclude template="cabecalho.cfm">
 <form class="form">    
<table width="100%" align="center" class="table table-bordered table-hover">
  <tr>
    <td align="left"><input type="button" class="botao" onClick="window.close()" value="Fechar"></td>
    <td colspan="8"><div align="center"><strong class="titulo2">Relatório Recursos alocados para Avaliação da Unidade</strong></div></td>
    <td colspan="2"><div align="center"><a href="Fechamento/<cfoutput>#sarquivo#</cfoutput>"><img src="icones/excel.jpg" width="50" height="35" border="0"></a></div></td>
  </tr>
  <cfset geralprevisto = 0>
  <cfset geralrealizado = 0>
  <cfset geraladinoturno = 0>
  <cfset geraldeslocamento = 0>
  <cfset geraldiarias = 0>
  <cfset geralpassagemaerea = 0>
  <cfset geralreembveicproprio = 0>
  <cfset geralrepousoremunerado = 0>
  <cfset geralressarcirempregado = 0>
  <cfset geraloutros = 0>
  <cfoutput query="rsRevisor">
    <cfquery datasource="#dsn_inspecao#" name="rsResultGeral">
        SELECT RIP_Resposta
        FROM Resultado_Inspecao
        WHERE RIP_NumInspecao='#INP_NumInspecao#'
    </cfquery>

    <cfquery name="rsC" dbtype = "query">
        SELECT RIP_Resposta 
        FROM rsResultGeral
        WHERE RIP_Resposta = 'C'
    </cfquery>
    <cfset totalC = rsC.recordcount>
    <cfquery name="rsN" dbtype = "query">
        SELECT RIP_Resposta 
        FROM rsResultGeral
        WHERE RIP_Resposta = 'N'
    </cfquery>
    <cfset totalN = rsN.recordcount>
    <cfquery name="rsE" dbtype = "query">
        SELECT RIP_Resposta 
        FROM rsResultGeral
        WHERE RIP_Resposta = 'E'
    </cfquery>
    <cfset totalE = rsE.recordcount>
    <cfquery name="rsV" dbtype = "query">
        SELECT RIP_Resposta 
        FROM rsResultGeral
        WHERE RIP_Resposta = 'V'
    </cfquery>
    <cfset totalV = rsV.recordcount>    
        <cfif rsRevisor.INP_Modalidade is 0>
            <cfset INPModalidade = 'PRESENCIAL'>
        <cfelseif rsRevisor.INP_Modalidade is 1>
            <cfset INPModalidade = 'A DISTÂNCIA'>
        <cfelse>
            <cfset INPModalidade = 'MISTA'>
        </cfif>	

        <tr>
        <td colspan="1" class="exibir" align="center"><strong>Unidade</strong></td>
        <td colspan="3"><strong class="exibir">#rsRevisor.INP_Unidade# - #rsRevisor.Und_Descricao#</strong></td>
        <td colspan="8"><strong class="exibir">Gerente unidade:&nbsp;#rsRevisor.INP_Responsavel#</strong></td>
        </tr>
        
        <tr>
            <td colspan="1" align="center"><strong class="exibir">Nº Avaliação</strong></td>
            <td colspan="1" align="center"><strong class="exibir">Modalidade</strong></td>
            <td colspan="1" align="center"><strong class="exibir">Qtd. Geral</strong></td>
            <td colspan="1" align="center"><strong class="exibir">Conforme</strong></td>
            <td colspan="1" align="center"><strong class="exibir">Não Conforme</strong></td>
            <td colspan="1" align="center"><strong class="exibir">Não Executa</strong></td>
            <td colspan="1" align="center"><strong class="exibir">Não Verificado</strong></td>
            <td colspan="1" align="center"><strong class="exibir">Despesas (Últ. atualiz.)</strong></td>
            <td colspan="2" align="center"><strong class="exibir">Despesas (Gestor(a))</strong></td>
        </tr> 
        
        <tr>
            <td align="center"><strong class="exibir">#INP_NumInspecao#</strong></td>
            <td align="center"><strong class="exibir">#INPModalidade#</strong></td>
            <td align="center"><strong class="exibir">#rsResultGeral.recordcount#</strong></td>
            <td align="center"><strong class="exibir">#totalC#</strong></td>
            <td align="center"><strong class="exibir">#totalN#</strong></td>
            <td align="center"><strong class="exibir">#totalE#</strong></td>
            <td colspan="1" align="center"><strong class="exibir">#totalV#</strong></td>
            <td colspan="1" align="center"><strong class="exibir">#inpdtconcluirdespesas#</strong></td>
            <td colspan="2" align="center"><strong class="exibir">#Usu_Apelido#</strong></td>
        </tr>  
        
        <tr class="exibir">
            <td colspan="1" align="center">
                <strong class="exibir">Valor previsto</strong>
            </td>
            <td colspan="1" align="center">
                <strong class="exibir">Adicional noturno</strong>
            </td>
            <td colspan="1" align="center">
                <strong class="exibir">Deslocamento</strong>
            </td>
            <td colspan="1" align="center">
                <strong class="exibir">Diárias</strong>
            </td>
            <td colspan="1" align="center">
                <strong class="exibir">Passagem aérea</strong>
            </td>
            <td colspan="1" align="center">
                <strong class="exibir">Reembolso veículo próprio</strong>
            </td>
            <td colspan="1" align="center">
                <strong class="exibir">Repouso remunerado</strong>
            </td>
            <td colspan="1" align="center">
                <strong class="exibir">Ressarcimento empregado</strong>
            </td>
            <td colspan="1" align="center">
                <strong class="exibir">Outros</strong>
            </td>
            <td colspan="1" align="center">
                <strong class="exibir">Realizado</strong>
            </td>
        </tr>

        <cfset vlrealiz = (INP_AdiNoturno + INP_Deslocamento + INP_Diarias + INP_PassagemArea + INP_ReembVeicProprio + INP_RepousoRemunerado + INP_RessarcirEmpregado + INP_Outros)>
        <cfset geralrealizado = geralrealizado + vlrealiz>
        <cfset geralprevisto = geralprevisto + INP_ValorPrevisto>
        <cfset geraladinoturno = geraladinoturno + INP_AdiNoturno>
        <cfset geraldeslocamento = geraldeslocamento + INP_Deslocamento>
        <cfset geraldiarias = geraldiarias + INP_Diarias>
        <cfset geralpassagemaerea = geralpassagemaerea + INP_PassagemArea>
        <cfset geralreembveicproprio = geralreembveicproprio + INP_ReembVeicProprio>
        <cfset geralrepousoremunerado = geralrepousoremunerado + INP_RepousoRemunerado>
        <cfset geralressarcirempregado = geralressarcirempregado + INP_RessarcirEmpregado>
        <cfset geraloutros = geraloutros + INP_Outros>  
        <tr class="exibir">
            <td colspan="1" align="center">
                <strong>#LSCurrencyFormat(INP_ValorPrevisto, "none")#</strong>
            </td>
            <td colspan="1" align="center">
                <strong>#LSCurrencyFormat(INP_AdiNoturno, "none")#</strong>
            </td>
            <td colspan="1" align="center">
                <strong>#LSCurrencyFormat(INP_Deslocamento, "none")#</strong>
            </td>
            <td colspan="1" align="center">
                <strong>#LSCurrencyFormat(INP_Diarias, "none")#</strong>
            </td>
            <td colspan="1" align="center">
                <strong>#LSCurrencyFormat(INP_PassagemArea, "none")#</strong>
            </td>
            <td colspan="1" align="center">
                <strong>#LSCurrencyFormat(INP_ReembVeicProprio, "none")#</strong>
            </td>
            <td colspan="1" align="center">
                <strong>#LSCurrencyFormat(INP_RepousoRemunerado, "none")#</strong>
            </td>  
            <td colspan="1" align="center">
                <strong>#LSCurrencyFormat(INP_RessarcirEmpregado, "none")#</strong>
            </td>
            <td colspan="1" align="center">
                <strong>#LSCurrencyFormat(INP_Outros, "none")#</strong>
            </td>
            <td colspan="1" align="center">
                <strong>#LSCurrencyFormat(vlrealiz, "none")#</strong>
            </td>  
        </tr>
        <tr class="exibir quebra"><td colspan="10"></td></tr>
    </cfoutput> 
    <cfoutput>
        <tr>
            <td colspan="10"><div align="center"><strong class="titulo2">Resumo Geral</strong></div></td>
        </tr>   
        <tr class="exibir">
            <td colspan="1" align="center">
                <strong class="exibir">Valor previsto</strong>
            </td>
            <td colspan="1" align="center">
                <strong class="exibir">Adicional noturno</strong>
            </td>
            <td colspan="1" align="center">
                <strong class="exibir">Deslocamento</strong>
            </td>
            <td colspan="1" align="center">
                <strong class="exibir">Diárias</strong>
            </td>
            <td colspan="1" align="center">
                <strong class="exibir">Passagem aérea</strong>
            </td>
            <td colspan="1" align="center">
                <strong class="exibir">Reembolso veículo próprio</strong>
            </td>
            <td colspan="1" align="center">
                <strong class="exibir">Repouso remunerado</strong>
            </td>
            <td colspan="1" align="center">
                <strong class="exibir">Ressarcimento empregado</strong>
            </td>
            <td colspan="1" align="center">
                <strong class="exibir">Outros</strong>
            </td>
            <td colspan="1" align="center">
                <strong class="exibir">Realizado</strong>
            </td>
        </tr>            
        <tr class="exibir">
            <td colspan="1" align="center">
                <strong>#LSCurrencyFormat(geralprevisto, "none")#</strong>
            </td>
            <td colspan="1" align="center">
                <strong>#LSCurrencyFormat(geraladinoturno, "none")#</strong>
            </td>
            <td colspan="1" align="center">
                <strong>#LSCurrencyFormat(geraldeslocamento, "none")#</strong>
            </td>
            <td colspan="1" align="center">
                <strong>#LSCurrencyFormat(geraldiarias, "none")#</strong>
            </td>
            <td colspan="1" align="center">
                <strong>#LSCurrencyFormat(geralpassagemaerea, "none")#</strong>
            </td>
            <td colspan="1" align="center">
                <strong>#LSCurrencyFormat(geralreembveicproprio, "none")#</strong>
            </td>
            <td colspan="1" align="center">
                <strong>#LSCurrencyFormat(geralrepousoremunerado, "none")#</strong>
            </td>  
            <td colspan="1" align="center">
                <strong>#LSCurrencyFormat(geralressarcirempregado, "none")#</strong>
            </td>
            <td colspan="1" align="center">
                <strong>#LSCurrencyFormat(geraloutros, "none")#</strong>
            </td>
            <td colspan="1" align="center">
                <strong>#LSCurrencyFormat(geralrealizado, "none")#</strong>
            </td>  
        </tr>
    </cfoutput> 
    <tr>
        <td colspan="10" align="left"><input type="button" class="botao" onClick="window.close()" value="Fechar"></td>
    </tr>   

</table>


</form>  
</body>
</html>


