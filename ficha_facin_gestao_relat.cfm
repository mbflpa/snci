<cfoutput>
<cfset url.ninsp='3200012025'>
<cfset url.unid='32300140'>
<cfset url.ngrup=230>
<cfset url.nitem=2>
<cfprocessingdirective pageEncoding ="utf-8">  
<!--- <cfdump var="#form#"> <cfdump var="#session#"> --->
<!---  <cfdump var="#url#">  --->
   

<cfset anoinsp = right(ninsp,4)>
	
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso, Usu_Matricula, Usu_Email 
	from usuarios 
	where Usu_login = '#cgi.REMOTE_USER#'
</cfquery>

<cfset grpacesso = ucase(Trim(qAcesso.Usu_GrupoAcesso))>

            

<cfquery name="qUsuario" datasource="#dsn_inspecao#">
  SELECT DISTINCT Usu_Apelido, Usu_Lotacao, Usu_LotacaoNome, Usu_DR, Usu_Email, Usu_Coordena
  FROM Usuarios
  WHERE Usu_Login = '#CGI.REMOTE_USER#'
  GROUP BY Usu_DR, Usu_Apelido, Usu_Lotacao, Usu_LotacaoNome, Usu_Email, Usu_Coordena
</cfquery>




<!--- <cfdump var="#url#"> <cfabort> --->

<!--- Nova consulta para verificar respostas das unidades --->
<cfquery name="qSituacaoResp" datasource="#dsn_inspecao#">
  SELECT Pos_Situacao_Resp, Pos_NomeArea, Pos_Area
  FROM ParecerUnidade
  WHERE Pos_Unidade='#unid#' AND Pos_Inspecao='#ninsp#' AND Pos_NumGrupo=#ngrup# AND Pos_NumItem=#nitem#
</cfquery>

<cfquery name="qResponsavel" datasource="#dsn_inspecao#">
    SELECT INP_Responsavel
    FROM Inspecao
    WHERE (INP_NumInspecao = '#ninsp#')
</cfquery>
<!--- Visualizacao de anexos --->
<cfquery name="qAnexos" datasource="#dsn_inspecao#">
  SELECT Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Codigo, Ane_Caminho
  FROM Anexos
  WHERE  Ane_NumInspecao = '#ninsp#' AND Ane_Unidade = '#unid#' AND Ane_NumGrupo = #ngrup# AND Ane_NumItem = #nitem# 
  order by Ane_Codigo
</cfquery>

<cfquery name="qCausa" datasource="#dsn_inspecao#">
  SELECT Cpr_Codigo, Cpr_Descricao FROM CausaProvavel WHERE Cpr_Codigo not in (select PCP_CodCausaProvavel from ParecerCausaProvavel
  WHERE PCP_Unidade='#unid#' AND PCP_Inspecao='#ninsp#' AND PCP_NumGrupo=#ngrup# AND PCP_NumItem=#nitem#)
  ORDER BY Cpr_Descricao
</cfquery>
<cfquery name="qSeiApur" datasource="#dsn_inspecao#">
	SELECT SEI_NumSEI FROM Inspecao_SEI 
	WHERE SEI_Unidade='#unid#' AND SEI_Inspecao='#ninsp#' AND SEI_Grupo=#ngrup# AND SEI_Item=#nitem#
	ORDER BY SEI_NumSEI
</cfquery>
<cfquery name="qProcSei" datasource="#dsn_inspecao#">
	SELECT PDC_ProcSEI, PDC_Processo, PDC_Modalidade,PDC_dtultatu FROM Inspecao_ProcDisciplinar
	WHERE PDC_Unidade='#unid#' AND PDC_Inspecao='#ninsp#' AND PDC_Grupo=#ngrup# AND PDC_Item=#nitem#
	ORDER BY PDC_ProcSEI
</cfquery>





<!--- Nova consulta para verificar respostas das unidades --->

 <cfquery name="qResposta" datasource="#dsn_inspecao#">
 SELECT Pos_Area, 
 Pos_NomeArea, 
 Pos_Situacao_Resp, 
 Pos_Parecer, 
 RIP_Recomendacoes, 
 RIP_Comentario, 
 RIP_Caractvlr, 
 RIP_Falta, 
 RIP_Sobra, 
 RIP_EmRisco, 
 RIP_Valor, 
 RIP_ReincInspecao, 
 RIP_ReincGrupo, 
 RIP_ReincItem, 
 RIP_Manchete,
 Dir_Descricao, 
 Dir_Codigo, 
 Pos_Processo, 
 Pos_Tipo_Processo, 
 Pos_Abertura, 
 Itn_Descricao, 
 Itn_TipoUnidade, 
 Itn_ValorDeclarado,
 Itn_ImpactarTipos,
 Itn_PTC_Seq,
 Pos_VLRecuperado, 
 Pos_DtPrev_Solucao, 
 Pos_DtPosic, 
 Pos_Sit_Resp_Antes,
 DATEDIFF(dd,Pos_DtPosic,GETDATE()) AS diasOcor, 
 Pos_SEI, 
 Pos_Situacao_Resp, 
 INP_DtInicInspecao, 
 INP_TNCClassificacao, 
 INP_Modalidade,
 Pos_NCISEI,
 Pos_ClassificacaoPonto, 
 Pos_PontuacaoPonto,
 Grp_Descricao,
 Pos_NumProcJudicial,
 TNC_ClassifInicio, 
 TNC_ClassifAtual,
 Und_Descricao
FROM Diretoria 
INNER JOIN (((Unidades 
INNER JOIN ((Inspecao 
INNER JOIN Resultado_Inspecao ON (INP_NumInspecao = RIP_NumInspecao) 
AND (INP_Unidade = RIP_Unidade)) 
INNER JOIN ParecerUnidade ON (RIP_NumItem = Pos_NumItem) AND (RIP_NumGrupo = Pos_NumGrupo) AND 
(RIP_NumInspecao = Pos_Inspecao) AND (RIP_Unidade = Pos_Unidade)) ON Und_Codigo = INP_Unidade) 
INNER JOIN Itens_Verificacao ON (Pos_NumItem = Itn_NumItem) AND (Pos_NumGrupo = Itn_NumGrupo) and (convert(char(4),RIP_Ano) = Itn_Ano)) 
INNER JOIN Grupos_Verificacao ON (Itn_Ano = Grp_Ano) AND (Itn_NumGrupo = Grp_Codigo) and (Itn_TipoUnidade = Und_TipoUnidade) and (INP_Modalidade = Itn_modalidade)) ON Dir_Codigo = Und_CodDiretoria
left JOIN TNC_Classificacao ON (RIP_NumInspecao = TNC_Avaliacao) AND (RIP_Unidade = TNC_Unidade)
 WHERE Pos_Unidade='#URL.unid#' AND Pos_Inspecao='#URL.ninsp#' AND Pos_NumGrupo=#URL.ngrup# AND Pos_NumItem=#URL.nitem#
</cfquery>

 
    
		  
<cfquery name="qInspetor" datasource="#dsn_inspecao#">
    SELECT IPT_MatricInspetor, Fun_Nome
    FROM Inspetor_Inspecao INNER JOIN Funcionarios ON IPT_MatricInspetor = Fun_Matric AND IPT_MatricInspetor =
    Fun_Matric WHERE IPT_NumInspecao = '#URL.Ninsp#'
</cfquery>

	  
<cfquery name="qAreaDaUnidade" datasource="#dsn_inspecao#">  
      SELECT Areas.Ars_Codigo, Areas.Ars_Sigla, Areas.Ars_Descricao
      FROM Unidades INNER JOIN Reops ON Unidades.Und_CodReop = Reops.Rep_Codigo INNER JOIN Areas ON Reops.Rep_CodArea = Areas.Ars_Codigo
      WHERE Areas.Ars_Status = 'A' AND Unidades.Und_Codigo=#URL.unid#
</cfquery>		
<cfset areaDaUnidade = 	'#qAreaDaUnidade.Ars_Descricao#'/>	  
<cfset vRecom = 0>
<cfset vRecomendacao = Trim(qResposta.RIP_Recomendacoes)>

<cfif vRecomendacao is ''>
   <cfset vRecom = 1>
</cfif>
</cfoutput>
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script type="text/javascript" src="ckeditor\ckeditor.js"></script>
</head>

<body style="background:#fff"> 
<cfoutput>
 <cfinclude template="cabecalho.cfm">
<table width="95%"  align="center" bordercolor="f7f7f7">
  <tr>
    <td height="20" colspan="5"><div align="center"><strong class="titulo2">Avaliar Resultados Geral - (FACIN)</strong></div></td>
  </tr>


  <form name="form1" method="post" action="">
	  <tr>
      <td width="95" class="exibir">Unidade</td>
      <td width="324"><strong class="exibir">#URL.Unid#</strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong class="exibir">#qResposta.Und_Descricao#</strong></td>
      </tr>
      <tr>
        <td width="81"><span class="exibir">Gerente unidade</span>:</td>
        <td width="237"><strong class="exibir">#qResponsavel.INP_Responsavel#</strong></td>
        </tr>
      <tr class="exibir">
        <td width="139" class="exibir">Inspetores</td>
                 <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>
                 <td colspan="6">-&nbsp;<cfloop query="qInspetor"><strong class="exibir">#qInspetor.Fun_Nome#</strong>&nbsp;<cfif qInspetor.currentrow neq qInspetor.recordcount><br>-&nbsp;</cfif></cfloop></td>
           </tr>
<cfif qResposta.INP_Modalidade is 0>
	<cfset INPModalidade = 'PRESENCIAL'>
<cfelseif qResposta.INP_Modalidade is 1>
    <cfset INPModalidade = 'A DISTÂNCIA'>
<cfelse>
    <cfset INPModalidade = 'MISTA'>
</cfif>		
    <tr class="exibir">
      <td>Nº Relatório</td>
      <td colspan="4">
        <table width="1030" border="0">
          <tr>
            <td width="228"><strong class="exibir">#URL.Ninsp#</strong></td>
            <td width="344"><span class="exibir">Início Avaliação:</span> &nbsp;<strong class="exibir">#DateFormat(qResposta.INP_DtInicInspecao,"dd/mm/yyyy")#</strong></td>         
            <td width="444"><span class="exibir">Modalidade:</span> <strong class="exibir">#INPModalidade#</strong></td>
          </tr>
      </table></td>
    </tr>
    </table>
		 <!---  ============= --->     
         </td>
    </tr>



 </form>

</table>
</cfoutput>
</body>

<script>
	            
</script>
</html>


