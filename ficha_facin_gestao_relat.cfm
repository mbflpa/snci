<cfoutput>
<cfprocessingdirective pageEncoding ="utf-8">  
<!--- <cfdump var="#form#"> <cfdump var="#session#"> --->
<!---  <cfdump var="#url#">  --->
   

 <cfquery name="rsFacin" datasource="#dsn_inspecao#">
    SELECT 
        RIP_Unidade, RIP_NumInspecao, RIP_NumGrupo, RIP_NumItem, FACA_Consideracao, FACA_Consideracao_Inspetor,
        RIP_Data_Avaliador, RIP_DtUltAtu_Revisor, Dir_Codigo, INP_DtInicInspecao, INP_DTConcluirRevisao,INP_RevisorDTInic, 
        INP_Modalidade, INP_Coordenador, INP_Responsavel, Und_Descricao, Usu_Apelido, Usu_LotacaoNome, Usu_DR,Fun_Nome
        FROM ((((Inspecao INNER JOIN Usuarios ON INP_RevisorLogin = Usu_Login) 
        INNER JOIN Unidades ON INP_Unidade = Unidades.Und_Codigo) 
        INNER JOIN Resultado_Inspecao ON (INP_NumInspecao = RIP_NumInspecao) AND (INP_Unidade = RIP_Unidade)) 
        INNER JOIN UN_Ficha_Facin_Avaliador ON (RIP_NumItem = FACA_Item) AND (RIP_NumGrupo = FACA_Grupo) AND (RIP_NumInspecao = FACA_Avaliacao) AND (RIP_Unidade = FACA_Unidade)) 
        INNER JOIN Diretoria ON Usu_DR = Dir_Codigo
        INNER JOIN Funcionarios ON FACA_Avaliador = Fun_Matric
        WHERE RIP_NumInspecao='#URL.ninsp#' and FACA_Avaliador = '#url.matr#'
</cfquery>

<cfquery name="rsAnalise" dbtype = "query">
    SELECT RIP_DtUltAtu_Revisor 
    FROM rsFacin
    order by RIP_DtUltAtu_Revisor desc
</cfquery>

<cfquery name="rsRevisor" datasource="#dsn_inspecao#">
    SELECT Dir_Sigla 
    FROM Diretoria 
    where '#rsFacin.Usu_DR#' = Dir_Codigo
</cfquery>
    
<cfquery name="qInspetor" datasource="#dsn_inspecao#">
    SELECT IPT_MatricInspetor, Fun_Nome, Usu_LotacaoNome,Dir_Sigla,INP_HrsPreInspecao, INP_DtInicDeslocamento, INP_DtFimDeslocamento, INP_HrsDeslocamento, INP_DtInicInspecao, INP_DtFimInspecao, INP_HrsInspecao, INP_DtEncerramento, INP_DTConcluirAvaliacao
    FROM Inspetor_Inspecao 
    INNER JOIN Inspecao ON (IPT_NumInspecao=INP_NumInspecao) AND (IPT_CodUnidade=INP_Unidade)
    INNER JOIN Funcionarios ON IPT_MatricInspetor = Fun_Matric AND IPT_MatricInspetor = Fun_Matric 
    INNER JOIN Usuarios ON Fun_Matric = Usu_Matricula
    INNER JOIN Diretoria ON Fun_DR = Dir_Codigo
    WHERE IPT_NumInspecao = '#URL.Ninsp#'
</cfquery>

</cfoutput>
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="public/bootstrap/bootstrap.min.css">
</head>

<body style="background:#fff"> 
<cfoutput>
 <cfinclude template="cabecalho.cfm">
<table width="95%"  align="left" class="table table-bordered">
  <tr>
    <td height="20" colspan="10"><div align="center"><strong class="titulo2">Avaliar Resultados Geral - (FACIN)</strong></div></td>
  </tr>
  <cfif rsFacin.INP_Modalidade is 0>
    <cfset INPModalidade = 'PRESENCIAL'>
<cfelseif rsFacin.INP_Modalidade is 1>
    <cfset INPModalidade = 'A DISTÂNCIA'>
<cfelse>
    <cfset INPModalidade = 'MISTA'>
</cfif>	

	
	<tr>
      <td width="95" class="exibir">Unidade</td>
      <td colspan="9"><strong class="exibir">#rsFacin.Und_Descricao#</strong></td>
    </tr>
    <tr>
        <td width="95" class="exibir">Nº Relatório</td>
        <td colspan="9"><strong class="exibir">#URL.Ninsp#</strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong class="exibir">Modalidade:</span>&nbsp;<strong class="exibir">#INPModalidade#</strong>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="exibir">Gerente unidade:</span>&nbsp;<strong class="exibir">#rsFacin.INP_Responsavel#</strong>
        </td>
    </tr> 
    <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>   
    <cfset col = 'Inspetores'>
    <cfloop query="qInspetor">
        <tr class="exibir">
            <td width="139" class="exibir">#col#</td>
            <td colspan="9">
                <cfif trim(rsFacin.INP_Coordenador) eq trim(qInspetor.IPT_MatricInspetor)>
                    <strong class="exibir">#qInspetor.Fun_Nome#</strong><strong>#qInspetor.Usu_LotacaoNome# - (SE-#trim(qInspetor.Dir_Sigla)#) - Coordenador(a)</strong>
                <cfelse>
                    <strong class="exibir">#qInspetor.Fun_Nome# - #qInspetor.Usu_LotacaoNome# - (SE-#trim(qInspetor.Dir_Sigla)#)</strong>
                </cfif>
            </td>
        </tr>
        <cfset col = ''>
    </cfloop>
    <tr class="exibir" colspan="9">
        <td class="exibir">#col#</td>
        <td>
            <strong class="exibir">Pré-Inspeção</strong>
        </td>
        <td>
            <strong class="exibir">Início Desloc.</strong>
        </td>
        <td>
            <strong class="exibir">Fim Desloc.</strong>
        </td>
        <td>
            <strong class="exibir">Horas Desloc.</strong>
        </td>
        <td>
            <strong class="exibir">Início Avaliação</strong>
        </td>
        <td>
            <strong class="exibir">Fim Avaliação</strong>
        </td>
        <td>
            <strong class="exibir">Horas Avaliação</strong>
        </td>
        <td>
            <strong class="exibir">Conclusão Avaliação</strong>
        </td>
        <td>
            <strong class="exibir">Últ.Transação</strong>
        </td>
    </tr>
    <tr class="exibir"  colspan="9">
        <td width="139" class="exibir">#col#</td>
        <td>
            <strong class="exibir">#qInspetor.INP_HrsPreInspecao# horas</strong>
        </td>
        <td>
            <strong class="exibir">#dateformat(qInspetor.INP_DtInicDeslocamento,"dd-mm-yyyy")#</strong>
        </td>
        <td>
            <strong class="exibir">#dateformat(qInspetor.INP_DtFimDeslocamento,"dd-mm-yyyy")#</strong>
        </td>
        <td>
            <strong class="exibir">#qInspetor.INP_HrsDeslocamento#</strong>
        </td>
        <td>
            <strong class="exibir">#dateformat(qInspetor.INP_DtInicInspecao,"dd-mm-yyyy")#</strong>
        </td>
        <td>
            <strong class="exibir">#dateformat(qInspetor.INP_DtFimInspecao,"dd-mm-yyyy")#</strong>
        </td>  
        <td>
            <strong class="exibir">#qInspetor.INP_HrsInspecao#</strong>
        </td>
        <td>
            <strong class="exibir">#dateformat(qInspetor.INP_DTConcluirAvaliacao,"dd-mm-yyyy")#</strong>
        </td>  
        <td>
            <strong class="exibir">#dateformat(rsAnalise.RIP_DtUltAtu_Revisor,"dd-mm-yyyy hh")#h</strong>
        </td>                
    </tr>
    
    <tr class="exibir"><td>&nbsp;</td></tr>
    <tr>
        <td width="95" class="exibir">Revisor(a)</td>
        <td colspan="9"><strong class="exibir">#rsFacin.Usu_Apelido# - #rsFacin.Usu_LotacaoNome# - (SE-#trim(rsRevisor.Dir_Sigla)#)</strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <strong class="exibir">Início Revisão:&nbsp;</strong><strong class="exibir">#dateformat(rsFacin.INP_RevisorDTInic,"dd-mm-yyyy hh")#h</strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <strong class="exibir">Conclusão Revisão:&nbsp;</strong><strong class="exibir">#dateformat(rsFacin.INP_DTConcluirRevisao,"dd-mm-yyyy")#</strong>
        </td>
    </tr>  
    <tr class="exibir"><td>&nbsp;</td></tr> 
    <tr>
        <td width="95" class="exibir">Nome Avaliado</td>
        <td colspan="9"><strong class="exibir">#rsFacin.Fun_Nome# </strong></td>
    </tr>
    <tr class="exibir"><td>&nbsp;</td></tr> 
</table>

<table width="95%"  align="left" class="table table-bordered">
<tr>
    <td width="139" class="exibir">FACIN</td>
    <td>
        <strong class="exibir">Grupo</strong>&nbsp;&nbsp;
    </td>
    <td>
        <strong class="exibir">Item</strong>&nbsp;&nbsp;
    </td>
    <td>
        <strong class="exibir">Consideração Revisor</strong>
    </td>
    <td>
        <strong class="exibir">Consideração Inspetor</strong>
    </td>
</tr>
<cfloop query="rsFacin">
    <tr>
        <td width="95" class="exibir"></td>
        <td>
            <strong class="exibir">#rsFacin.RIP_NumGrupo#</strong>
        </td>
        <td>
            <strong class="exibir">#rsFacin.RIP_NumItem#</strong>
        </td>
        <td>
            <textarea name="" cols="100" rows="5" wrap="VIRTUAL" class="form" readonly>#rsFacin.FACA_Consideracao#</textarea>
        </td>
        <td>
            <textarea name="" cols="100" rows="5" wrap="VIRTUAL" class="form" readonly>#rsFacin.FACA_Consideracao_Inspetor#</textarea>
        </td>
    </tr> 
    <tr class="exibir"><td>&nbsp;</td></tr>
</cfloop>   
</table>
</cfoutput>
</body>

<script>
	            
</script>
</html>


