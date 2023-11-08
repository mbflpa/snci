<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
</head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<body text="FFFFFF" link="FFFFFF" vlink="FFFFFF" alink="FFFFFF" class="link1">

<a name="Inicio" id="Inicio"></a>
<cfinclude template="cabecalho.cfm">
<cfif isDefined("FORM.nome_arquivo")>

<cffile action="read" file="#GetDirectoryFromPath(gettemplatepath())#Dados\#FORM.nome_arquivo#" variable="XmlDoc">
<!---Lendo nosso arquivo .xml--->
<cfset xml = XmlParse(XmlDoc)>
<!---Converte o string pra XML--->

<!---O array apresenta o tipo de arquivo + o nome da chave + o nome da chave primaria do xml --->
<cfset arq_ins = 0>
<cfset arq_rej = 0>
<cfset verifica = false>
<cfset sflag = 0>


<!--- Insere dados com xml na tabela Numera_Inspecao --->
<cfquery name="qVerificaNumera" datasource="#dsn_inspecao#">
SELECT NIP_NumInspecao
FROM Numera_Inspecao
WHERE NIP_Unidade = '#xml.rootelement.dados[1].RIP_Unidade.XmlText#' AND NIP_NumInspecao ='#xml.rootelement.dados[1].RIP_NumInspecao.XmlText#'
</cfquery>

<cfdump var="#qVerificanumera#">


<cfif qVerificaNumera.recordcount is 0>
<cfquery datasource="#dsn_inspecao#">
INSERT INTO Numera_Inspecao (NIP_Unidade, NIP_NumInspecao, NIP_DtIniPrev, NIP_Situacao, NIP_DtUltAtu, NIP_UserName)
VALUES ('#xml.rootelement.dados[1].RIP_Unidade.XmlText#', '#xml.rootelement.dados[1].RIP_NumInspecao.XmlText#', CONVERT(DATETIME, '#xml.rootelement.dados[1].INP_DtInicInspecao.XmlText#', 103), 'A', CONVERT(char, getdate(), 102), '#xml.rootelement.dados[1].RIP_UserName.XmlText#')
</cfquery>
</cfif>
<!--- fim Insert Numera_Inspecao --->


<!--- Insere dados com xml na tabela Inspecao --->
<cfquery name="qVerificaInspecao" datasource="#dsn_inspecao#">
SELECT INP_NumInspecao
FROM Inspecao
WHERE INP_Unidade = '#xml.rootelement.dados[1].RIP_Unidade.XmlText#' AND INP_NumInspecao ='#xml.rootelement.dados[1].RIP_NumInspecao.XmlText#'
</cfquery>

<cfdump var="#qVerificaInspecao#">



<cfif qVerificaInspecao.recordcount is 0>
<cfquery datasource="#dsn_inspecao#">
INSERT INTO Inspecao (INP_Unidade, INP_NumInspecao, INP_HrsPreInspecao, INP_DtInicDeslocamento, INP_DtFimDeslocamento, INP_HrsDeslocamento, INP_DtInicInspecao, INP_DtFimInspecao, INP_HrsInspecao, INP_Situacao, INP_DtEncerramento, INP_Coordenador, INP_Responsavel, INP_DtUltAtu, INP_UserName, INP_Motivo)
VALUES ('#xml.rootelement.dados[1].RIP_Unidade.XmlText#', '#xml.rootelement.dados[1].RIP_NumInspecao.XmlText#', '#xml.rootelement.dados[1].INP_HrsPreInspecao.XmlText#', CONVERT(DATETIME, '#xml.rootelement.dados[1].INP_DtInicDeslocamento.XmlText#', 103), CONVERT(DATETIME, '#xml.rootelement.dados[1].INP_DtFimDeslocamento.XmlText#', 103),
'#xml.rootelement.dados[1].INP_HrsDeslocamento.XmlText#', CONVERT(DATETIME, '#xml.rootelement.dados[1].INP_DtInicInspecao.XmlText#', 103), CONVERT(char, GETDATE(), 102), '#xml.rootelement.dados[1].INP_HrsInspecao.XmlText#', 'CO', convert(char, getdate(), 102), '#xml.rootelement.dados[1].INP_Coordenador.XmlText#',
'#xml.rootelement.dados[1].INP_Responsavel.XmlText#', CONVERT(DATETIME, GETDATE(), 103), '#xml.rootelement.dados[1].RIP_UserName.XmlText#', '#xml.rootelement.dados[1].INP_Motivo.XmlText#')
</cfquery>
</cfif>

<!--- fim Insert Inspecao --->


<cfquery name="qVerificaResultado" datasource="#dsn_inspecao#">
SELECT RIP_NumInspecao
FROM Resultado_Inspecao
WHERE RIP_Unidade = '#xml.rootelement.dados[i].RIP_Unidade.XmlText#' AND RIP_NumInspecao = '#xml.rootelement.dados[i].RIP_NumInspecao.XmlText#' AND RIP_NumGrupo = #xml.rootelement.dados[i].RIP_NumGrupo.XmlText# AND RIP_NumItem = #xml.rootelement.dados[i].RIP_NumItem.XmlText#
</cfquery>


<cfdump var="#qVerificaResultado#">
<cfabort>

<cfloop from="1" to="#ArrayLen(xml.rootelement.dados)#" index="i">
<cftry>
<!--- Insere dados com xml na tabela Resultado_Inspecao --->

<cfquery name="qVerificaResultado" datasource="#dsn_inspecao#">
SELECT RIP_NumInspecao
FROM Resultado_Inspecao
WHERE RIP_Unidade = '#xml.rootelement.dados[i].RIP_Unidade.XmlText#' AND RIP_NumInspecao = '#xml.rootelement.dados[i].RIP_NumInspecao.XmlText#' AND RIP_NumGrupo = #xml.rootelement.dados[i].RIP_NumGrupo.XmlText# AND RIP_NumItem = #xml.rootelement.dados[i].RIP_NumItem.XmlText#
</cfquery>


<cfdump var="#qVerificaResultado#">
<cfabort>



<cfif qVerificaResultado.recordcount is 0>

<cfquery datasource="#dsn_inspecao#">
INSERT INTO Resultado_Inspecao (RIP_Unidade, RIP_NumInspecao, RIP_NumGrupo, RIP_NumItem, RIP_CodDiretoria, RIP_CodReop, RIP_Ano, RIP_Resposta, RIP_Comentario, RIP_DtUltAtu, RIP_UserName, RIP_Recomendacoes, RIP_Valor)
VALUES (
'#xml.rootelement.dados[i].RIP_Unidade.XmlText#',
'#xml.rootelement.dados[i].RIP_NumInspecao.XmlText#',
 #xml.rootelement.dados[i].RIP_NumGrupo.XmlText#,
 #xml.rootelement.dados[i].RIP_NumItem.XmlText#,
'#xml.rootelement.dados[i].RIP_CodDiretoria.XmlText#',
'#xml.rootelement.dados[i].RIP_CodReop.XmlText#',
 #xml.rootelement.dados[i].RIP_Ano.XmlText#,
'#xml.rootelement.dados[i].RIP_Resposta.XmlText#',
 <cfset Comentario = '#xml.rootelement.dados[i].RIP_Comentario.XmlText#'>
 <!--- As linhas abaixo servem para substituir o uso caracteres especiais, a fim de evitar erros em instruções SQL --->
 <cfset Comentario = Replace(Comentario,'"','','All')>
 <cfset Comentario = Replace(Comentario,"'","","All")>
 <cfset Comentario = Replace(Comentario,'&','','All')>
 <cfset Comentario = Replace(Comentario,'*','','All')>
 <cfset Comentario = Replace(Comentario,'%','','All')>
 '#Comentario#',
 CONVERT(DATETIME, GETDATE(), 103),
'#xml.rootelement.dados[i].RIP_UserName.XmlText#',
'#xml.rootelement.dados[i].RIP_Recomendacoes.XmlText#',
'#xml.rootelement.dados[i].RIP_Valor.XmlText#')
</cfquery>
<!--- fim insert Resultado --->

<!--- Insere dados com xml na tabela Inspetor_Inspecao --->
<cfif sflag is 0>
<cfset numocor = 1>
<cfset numocor2 = 1>
<cfloop from="1" to="#val(Len(xml.rootelement.dados[i].IPT_MatricInspetor.XmlText) / 8)#" index="j">
<cfset smatr = mid(xml.rootelement.dados[i].IPT_MatricInspetor.XmlText,numocor,8)>
<!--- <cfset snhpr = trim(mid(xml.rootelement.dados[i].IPT_NumHrsPreInsp.XmlText,numocor2,4))>
<cfset snhde = trim(mid(xml.rootelement.dados[i].IPT_NumHrsDesloc.XmlText,numocor2,4))>
<cfset snhin = trim(mid(xml.rootelement.dados[i].IPT_NumHrsInsp.XmlText,numocor2,4))> --->

<cfset snhpr = ListGetAt(xml.rootelement.dados[i].IPT_NumHrsPreInsp.XmlText,j," ")>
<cfset snhde = ListGetAt(xml.rootelement.dados[i].IPT_NumHrsDesloc.XmlText,j," ")>
<cfset snhin = ListGetAt(xml.rootelement.dados[i].IPT_NumHrsInsp.XmlText,j," ")>

<cfquery datasource="#dsn_inspecao#">
insert into Inspetor_Inspecao (IPT_CodUnidade, IPT_NumInspecao, IPT_MatricInspetor, IPT_DtInicInsp, IPT_DtFimInsp, IPT_DtInicDesloc, IPT_DtFimDesloc, IPT_NumHrsPreInsp, IPT_NumHrsdesloc, IPT_NumHrsInsp, IPT_DtUltAtu, IPT_UserName)
values ('#xml.rootelement.dados[i].RIP_Unidade.XmlText#', '#xml.rootelement.dados[i].RIP_NumInspecao.XmlText#', '#smatr#', CONVERT(DATETIME, '#xml.rootelement.dados[i].INP_DtInicInspecao.XmlText#', 103), CONVERT(DATETIME, '#xml.rootelement.dados[i].INP_DtFimInspecao.XmlText#', 103), CONVERT(DATETIME, '#xml.rootelement.dados[i].INP_DtInicDeslocamento.XmlText#', 103), CONVERT(DATETIME, '#xml.rootelement.dados[i].INP_DtFimDeslocamento.XmlText#', 103), '#snhpr#', '#snhde#', '#snhin#', CONVERT(DATETIME, '#xml.rootelement.dados[i].RIP_DtUltAtu.XmlText#', 103), '#xml.rootelement.dados[i].RIP_UserName.XmlText#')
</cfquery>

<cfset numocor = numocor + 8>
<cfset numocor2 = numocor2 + 4>
</cfloop>
 <cfset sflag = 1>
</cfif>
<!--- fim update Inspecao --->

<cfset arq_ins = arq_ins + 1>

<cfelse>

<cfset arq_rej = arq_rej + 1>
</cfif>

<cfset verifica = true>

<cfcatch type="database">
<!--- 	<cfoutput>#smatr#-#snhpr#-#snhde#-#snhin#</cfoutput>
<cfdump var="#cfcatch#">
<cfabort> --->
<script>alert('Ocorreu um erro durante esta operação! Favor verificar novamente os dados, ou contacte o administrador do sistema!'+'grupo'+#xml.rootelement.dados[i].RIP_NumGrupo.XmlText#+'item'+#xml.rootelement.dados[i].RIP_NumItem.XmlText#)</script>
<a href="" onClick="history.back()">Voltar para a página anterior</a>
 </cfcatch>
 </cftry>
</cfloop>
<!--- Fim Insere Resultado_Inspecao --->

<!--- Insere dados na tabela ProcessoParecerUnidade (índice do vetor = 1, primeiro registro do arquivo xml) --->
<cfquery datasource="#dsn_inspecao#" name="qVerificaInspecao">
SELECT Pro_Unidade
FROM ProcessoParecerUnidade
WHERE Pro_Unidade = '#xml.rootelement.dados[1].RIP_Unidade.XmlText#' AND Pro_Inspecao = '#xml.rootelement.dados[1].RIP_NumInspecao.XmlText#'
</cfquery>

<cfif qVerificaInspecao.recordCount is 0>
<cfquery datasource="#dsn_inspecao#">
INSERT INTO ProcessoParecerUnidade (Pro_Unidade, Pro_Inspecao, Pro_Situacao, Pro_DtEncerr, Pro_username, Pro_dtultatu) VALUES (
'#xml.rootelement.dados[1].RIP_Unidade.XmlText#', '#xml.rootelement.dados[1].RIP_NumInspecao.XmlText#', 'AB', NULL, '#xml.rootelement.dados[1].RIP_UserName.XmlText#', GETDATE())
</cfquery>
</cfif>
<!---Fim Insere ProcessoParecerUnidade --->

<!---Insere dados na tabela ParecerUnidade (Caso o dado não exista) --->
<cfloop from="1" to="#ArrayLen(xml.rootelement.dados)#" index="i">
<cfif  xml.rootelement.dados[i].RIP_Resposta.XmlText is 'N'>
<cfquery datasource="#dsn_inspecao#" name="qVerificaParecer">
  SELECT Pos_Unidade FROM ParecerUnidade WHERE Pos_Unidade = '#xml.rootelement.dados[i].RIP_Unidade.XmlText#' AND Pos_Inspecao = '#xml.rootelement.dados[i].RIP_NumInspecao.XmlText#' AND Pos_NumGrupo = #xml.rootelement.dados[i].RIP_NumGrupo.XmlText# AND Pos_NumItem = #xml.rootelement.dados[i].RIP_NumItem.XmlText#
</cfquery>

<cfif qVerificaParecer.recordCount is 0>
<cfquery datasource="#dsn_inspecao#">
INSERT INTO ParecerUnidade (Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_NomeResp, Pos_Situacao, Pos_Parecer, Pos_co_ci, Pos_dtultatu, Pos_username, Pos_aval_dinsp, Pos_Situacao_Resp) VALUES (
'#xml.rootelement.dados[i].RIP_Unidade.XmlText#', '#xml.rootelement.dados[i].RIP_NumInspecao.XmlText#', #xml.rootelement.dados[i].RIP_NumGrupo.XmlText#, #xml.rootelement.dados[i].RIP_NumItem.XmlText#, CONVERT(char, GETDATE(), 102), '#CGI.REMOTE_USER#', 'RE', '', 'INTRANET', CONVERT(char, GETDATE(), 102), '#xml.rootelement.dados[i].RIP_UserName.XmlText#', NULL, '0')
</cfquery>
<!---Fim Insere ParecerUnidade --->

<!--- Inserindo dados dados na tabela Andamento --->
 <cfquery datasource="#dsn_inspecao#">
     insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_Orgao_Solucao, And_HrPosic ) values ('#xml.rootelement.dados[i].RIP_NumInspecao.XmlText#', '#xml.rootelement.dados[i].RIP_Unidade.XmlText#', #xml.rootelement.dados[i].RIP_NumGrupo.XmlText#, #xml.rootelement.dados[i].RIP_NumItem.XmlText#, convert(char, getdate(), 102), '#CGI.REMOTE_USER#', '0', '#xml.rootelement.dados[i].RIP_Unidade.XmlText#', CONVERT(char, GETDATE(), 108))
 </cfquery>
 <!---Fim Insere Andamento --->

 <!--- Inserindo dados dados na tabela Analise --->
<cfquery datasource="#dsn_inspecao#">
    insert into Analise (Ana_NumInspecao, Ana_Unidade, Ana_NumGrupo, Ana_NumItem, Ana_Col01, Ana_Col02, Ana_Col03, Ana_Col04, Ana_Col05, Ana_Col06, Ana_Col07, Ana_Col08, Ana_Col09) values ('#xml.rootelement.dados[i].RIP_NumInspecao.XmlText#', '#xml.rootelement.dados[i].RIP_Unidade.XmlText#', #xml.rootelement.dados[i].RIP_NumGrupo.XmlText#, #xml.rootelement.dados[i].RIP_NumItem.XmlText#, '0', '0', '0', '0', '0', '0', '0', '0', '0')
</cfquery>
<!---Fim Insere Analise --->
</cfif>
</cfif>
</cfloop>

<!--- Esclui arquivo xml adicionado com sucesso --->
<cfset arquivo = getDirectoryFromPath(getTemplatePath()) & 'Dados\' & FORM.nome_arquivo>
<cfif verifica is true And FileExists(arquivo)>
   <cffile action="delete" file="#arquivo#">
</cfif>
<table width="780">
	<tr>
		<td width="19%" class="titulos">Registros Incluídos:</td>
		<td width="81%"><cfoutput><span class="titulosClaro">#arq_ins#</span></cfoutput></td>
	</tr>
	<tr>
		<td class="titulos">Registros Rejeitados:</td>
		<td><cfoutput><span class="titulosClaro">#arq_rej#</span></cfoutput></td>
	</tr>
	<tr>
	  <td class="titulos">&nbsp;</td>
	  <td>&nbsp;</td>
	  </tr>
	<tr>
	  <td colspan="2" class="titulos"><center>
	  	<input type="button" class="botao" onClick="window.open('arquivo_dbins_transmitir.cfm','_self')" value="Voltar">
		&nbsp;&nbsp;&nbsp;
	    <input type="button" class="botao" onClick="window.close()" value="Sair">
	    </center></td>
	  </tr>
</table>
<cfelse>
<table width="780">
	<tr>
	  <td class="titulos">&nbsp;</td>
	  <td>&nbsp;</td>
	</tr>
	<tr>
	  <!--- Esta mensagem aparece caso o arquivo de inapeção não seja transmitido. --->
	  <td colspan="3" class="titulos">Não foi possível concluir esta operação. Arquivo não localizado.</td>
	</tr>
	<tr>
	  <td colspan="2" class="titulos"><center>
	  	<input type="button" class="botao" onClick="window.open('arquivo_dbins_transmitir.cfm','_self')" value="Voltar">
		&nbsp;&nbsp;&nbsp;
	    <input type="button" class="botao" onClick="window.close()" value="Sair">
	    </center></td>
	  </tr>
</table>
</cfif>
</body>
</html>