<cfprocessingdirective pageEncoding ="utf-8"/>
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>  
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
</head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">

<body text="FFFFFF" link="FFFFFF" vlink="FFFFFF" alink="FFFFFF" class="link1">

<cfif isDefined("FORM.nome_arquivo")>

	<cffile action="read" file="#GetDirectoryFromPath(gettemplatepath())#Dados\#FORM.nome_arquivo#" variable="XmlDoc">
	<!---Lendo nosso arquivo .xml--->
	<cfset XmlDoc = Replace(XmlDoc, "&", "&amp;", "All")>
	<cfset xml = XmlParse(XmlDoc)>
	<!---Converte o string pra XML--->

	<!---O array apresenta o tipo de arquivo + o nome da chave + o nome da chave primaria do xml --->
	<cfset arq_ins = 0> <!--- Arquivos aprovados para inserir --->
	<cfset arq_rej = 0> <!--- Arquivos rejeitados --->
	<cfset arq_inv = 0> <!--- Arquivos inválidos (em branco) --->
	<cfset verifica = false>
	<cfset sflag = 0>
	<cfset qtdItensInspecao = 0>
	<cfset anoinsp = right(xml.rootelement.dados[1].RIP_NumInspecao.XmlText,4)>
	
<!---     <cfset inpModalidade = 0> --->
<cfset inpModalidade = #xml.rootelement.dados[1].INP_Modalidade.XmlText#>
<cfquery name="qVerificaTipoUnidade" datasource="#dsn_inspecao#">
  SELECT Und_Codigo, Und_CodReop, Und_TipoUnidade FROM Unidades
  WHERE Und_Codigo = '#xml.rootelement.dados[1].RIP_Unidade.XmlText#'
</cfquery>
<cfquery name="qTotPontos" datasource="#dsn_inspecao#">
SELECT count(TUI_ItemVerif) as qItens from Itens_Verificacao 
inner join TipoUnidade_ItemVerificacao on Itn_Ano = Tui_Ano and Itn_NumItem = TUI_ItemVerif and Itn_NumGrupo = tui_grupoItem
where Itn_Ano = '#anoinsp#' and itn_situacao = 'A' and tui_modalidade = '#xml.rootelement.dados[1].INP_Modalidade.XmlText#' and tui_TipoUnid=#qVerificaTipoUnidade.Und_TipoUnidade#
</cfquery>
<cfset qtdItensInspecao = qTotPontos.qItens>
	<cfloop from="1" to="#ArrayLen(xml.rootelement.dados)#" index="i">
		<!--- <cfquery name="qVerificaTipoUnidade" datasource="#dsn_inspecao#">
		  SELECT Und_Codigo, Und_CodReop, Und_TipoUnidade FROM Unidades
		  WHERE Und_Codigo = '#xml.rootelement.dados[i].RIP_Unidade.XmlText#'
		</cfquery>
        <cfset inpModalidade = #xml.rootelement.dados[i].INP_Modalidade.XmlText#>
		<cfswitch expression="#qVerificaTipoUnidade.Und_TipoUnidade#">
		    <cfcase value="4">
				<!--- CDD --->
				<cfset qtdItensInspecao = 46>
			</cfcase>
			<cfcase value="5">
				<!--- CTE --->
				<cfset qtdItensInspecao = 62>
			</cfcase>
			<cfcase value="6">
				<!--- CTCE --->
				<cfset qtdItensInspecao = 83>
			</cfcase>
			<cfcase value="8">
				<!--- CTC  --->
				<cfset qtdItensInspecao = 69>
			</cfcase>
			<cfcase value="9">
			    <!--- AC --->
				<cfif inpModalidade eq 0><cfset qtdItensInspecao = 47></cfif>
				<cfif inpModalidade eq 1><cfset qtdItensInspecao = 23></cfif>
			</cfcase>
			<cfcase value="10">
				<!--- GCCAP --->
				<cfset qtdItensInspecao = 30>
			</cfcase>
			<cfcase value="12">
				<!--- AGF --->
				<cfset qtdItensInspecao = 35>
			</cfcase>
			<cfcase value="21">
				<!--- CTC com GCCAP --->
				<cfset qtdItensInspecao = 58>
			</cfcase>
			<cfcase value="22">
				<!--- CTE com GCCAP --->
				<cfset qtdItensInspecao = 59>
			</cfcase>
			<cfcase value="23">
				<!--- CTCE com GCCAP --->
				<cfset qtdItensInspecao = 68>
			</cfcase>
			<cfcase value="29">
				<!--- CEE --->
				<cfset qtdItensInspecao = 43>
			</cfcase>
<!---             <cfcase value="30">
				<!--- AC-Remota --->
				<cfset inpModalidade = 1>
				<cfset qtdItensInspecao = 23>
			</cfcase>			 --->
		 </cfswitch> --->


 <!---  <cftry>  --->
<!--- Verifica dados com xml na tabela Resultado_Inspecao --->

		<cfquery name="qVerificaResultado" datasource="#dsn_inspecao#">
		  SELECT RIP_NumInspecao, RIP_Resposta, RIP_NumGrupo
		  FROM Resultado_Inspecao
		  WHERE RIP_Unidade = '#xml.rootelement.dados[i].RIP_Unidade.XmlText#' AND RIP_NumInspecao = '#xml.rootelement.dados[i].RIP_NumInspecao.XmlText#' AND RIP_NumGrupo = #xml.rootelement.dados[i].RIP_NumGrupo.XmlText# AND RIP_NumItem = #xml.rootelement.dados[i].RIP_NumItem.XmlText#
		</cfquery>


		<cfif qVerificaResultado.recordcount is 0>

<!--- Insere dados com xml na tabela Inspetor_Inspecao --->
			<cfif sflag is 0>
				<cfset numocor = 1>
				<cfset numocor2 = 1>
				<cfloop from="1" to="#val(Len(xml.rootelement.dados[i].IPT_MatricInspetor.XmlText) / 8)#" index="j">
					<cfset smatr = mid(xml.rootelement.dados[i].IPT_MatricInspetor.XmlText,numocor,8)>
					<cfset snhpr = ListGetAt(xml.rootelement.dados[i].IPT_NumHrsPreInsp.XmlText,j," ")>
					<cfset snhde = ListGetAt(xml.rootelement.dados[i].IPT_NumHrsDesloc.XmlText,j," ")>
					<cfset snhin = ListGetAt(xml.rootelement.dados[i].IPT_NumHrsInsp.XmlText,j," ")>

					<cfset numocor = numocor + 8>
					<cfset numocor2 = numocor2 + 4>
				</cfloop>
			    <cfset sflag = 1>
			</cfif>
<!--- fim update Inspecao --->

			<cfset arq_ins = arq_ins + 1>

<!--- Verifica se o campo RIP_Resposta é inválido --->
			<cfif  Len(Trim(xml.rootelement.dados[i].RIP_Resposta.XmlText)) is 0>
			  <cfset arq_inv = arq_inv + 1>
			</cfif>
		<cfelse>
			<cfset arq_rej = arq_rej + 1>
		</cfif>

		<cfset verifica = true>

	  <!---  <cfcatch type="database"> --->
	<!--- 	<cfoutput>#smatr#-#snhpr#-#snhde#-#snhin#</cfoutput>
	<cfdump var="#cfcatch#">--->
<!--- 	<cfabort>
		<script>alert('Ocorreu um erro durante esta operação! Favor verificar novamente os dados, ou contacte o administrador do sistema!'+'grupo'+#xml.rootelement.dados[i].RIP_NumGrupo.XmlText#+'item'+#xml.rootelement.dados[i].RIP_NumItem.XmlText#)</script>
	<a href="" onClick="history.back()">Voltar para a página anterior</a>
	  </cfcatch>
     </cftry>  --->
  </cfloop>
<!--- Fim Insere Resultado_Inspecao --->

<!--- Verifica dados na tabela ProcessoParecerUnidade (índice do vetor = 1, primeiro registro do arquivo xml) --->
	<cfquery datasource="#dsn_inspecao#" name="qVerificaInspecao">
	  SELECT Pro_Unidade
	  FROM ProcessoParecerUnidade
	  WHERE Pro_Unidade = '#xml.rootelement.dados[1].RIP_Unidade.XmlText#' AND Pro_Inspecao = '#xml.rootelement.dados[1].RIP_NumInspecao.XmlText#'
	</cfquery>

<!---Verifica dados na tabela ParecerUnidade (Caso o dado não exista) --->
<cfloop from="1" to="#ArrayLen(xml.rootelement.dados)#" index="i">
	<cfif  xml.rootelement.dados[i].RIP_Resposta.XmlText is 'N'>
		<cfquery datasource="#dsn_inspecao#" name="qVerificaParecer">
		  SELECT Pos_Unidade FROM ParecerUnidade WHERE Pos_Unidade = '#xml.rootelement.dados[i].RIP_Unidade.XmlText#' AND Pos_Inspecao = '#xml.rootelement.dados[i].RIP_NumInspecao.XmlText#' AND Pos_NumGrupo = #xml.rootelement.dados[i].RIP_NumGrupo.XmlText# AND Pos_NumItem = #xml.rootelement.dados[i].RIP_NumItem.XmlText#
		</cfquery>

    </cfif>

</cfloop>

<!--- Se a quantidade de elementos no XML for diferente de 54 OU se a análise retornou registros rejeitados => exibir detalhes e abortar a inclusão do XML --->
<cfif (ArrayLen(xml.rootelement.dados) neq qtdItensInspecao) OR arq_rej gt 0 OR arq_inv gt 0>
<!--- Esclui arquivo xml adicionado com sucesso --->
<cfset arquivo = getDirectoryFromPath(getTemplatePath()) & 'Dados\' & FORM.nome_arquivo>
<cfif verifica is true And FileExists(arquivo)>
   <cffile action="delete" file="#arquivo#">
</cfif>
<!--- <cfset total_rejeitados = arq_rej + arq_inv> --->
<cfset total_rejeitados = ArrayLen(xml.rootelement.dados)>
<cfset total_aprovados = arq_ins - total_rejeitados>
<cfset msg_erro = 'Processamento interrompido.' & chr(13)>

<cfif (ArrayLen(xml.rootelement.dados) neq qtdItensInspecao)>
  <cfset msg_erro = msg_erro & 'Quantidade de registros diferente da quantidade de itens. ' & chr(13)>
</cfif>
<cfif arq_rej gt 0>
  <cfset msg_erro = msg_erro & 'Quantidade de itens duplicados: ' & arq_rej & '.' & chr(13)>
</cfif>

<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>

<table width="80%" align="center">
	<tr valign="middle">
		<td width="21%" class="titulos">Registros aprovados:</td>
		<td width="22%" class="titulos"><cfoutput><span class="titulosClaro">#total_aprovados#</span></cfoutput></td>
		<!--- <td colspan="2" class="titulos"><cfoutput>TESTEXML: #testexml# ARRAY: #ArrayLen(xml.rootelement.dados)#</cfoutput></td> --->
	  </tr>
	<tr>
		<td class="titulos">Registros rejeitados:</td>
		<td class="titulos"><cfoutput><span class="titulosClaro">#total_rejeitados#</span></cfoutput></td>
		<td colspan="2" class="titulos"><cfoutput></cfoutput></td>
	  </tr>
	<tr>
	  <td colspan="3" class="titulos"><cfoutput>#msg_erro#</cfoutput></td>
	</tr>
	  <tr>
	  <cfif arq_inv gt 0>
         <td colspan="3" class="titulos">Registros não foram avaliados, como Não-Conforme, Conforme, Não Executa Tarefa e Não Verificado.</td>
      </cfif>
	  </tr>
	<tr>
	  <td colspan="4" class="titulos">&nbsp;</td>
	  </tr>
	<tr>
	  <td colspan="4" class="titulos"><center>
	  	<input type="button" class="botao" onClick="window.open('arquivo_dbins_transmitir.cfm?flush=true','_self')" value="Voltar">
		&nbsp;&nbsp;&nbsp;
	    <input type="button" class="botao" onClick="window.close()" value="Sair">
	    </center></td>
	  </tr>
</table>
<cfabort>
</cfif>

</cfif>

<a name="Inicio" id="Inicio"></a>
<cfinclude template="cabecalho.cfm">
<cfif isDefined("FORM.nome_arquivo")>

<cffile action="read" file="#GetDirectoryFromPath(gettemplatepath())#Dados\#FORM.nome_arquivo#" variable="XmlDoc">
<!---Lendo nosso arquivo .xml--->


    <cfset XmlDoc = Replace(XmlDoc, "&", "&amp;", "All")>
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

<cfif qVerificaNumera.recordcount is 0>
<cfquery datasource="#dsn_inspecao#">
  INSERT INTO Numera_Inspecao (NIP_Unidade, NIP_NumInspecao, NIP_DtIniPrev, NIP_Situacao, NIP_DtUltAtu, NIP_UserName)
  VALUES ('#xml.rootelement.dados[1].RIP_Unidade.XmlText#', '#xml.rootelement.dados[1].RIP_NumInspecao.XmlText#', CONVERT(DATETIME, '#xml.rootelement.dados[1].INP_DtInicInspecao.XmlText#', 103), 'A', CONVERT(char, getdate(), 120), '#xml.rootelement.dados[1].RIP_UserName.XmlText#')
</cfquery>
</cfif>

<!--- fim Insert Numera_Inspecao --->

<!--- Insere dados com xml na tabela Inspecao --->
<cfquery name="qVerificaInspecao" datasource="#dsn_inspecao#">
SELECT INP_NumInspecao
FROM Inspecao
WHERE INP_Unidade = '#xml.rootelement.dados[1].RIP_Unidade.XmlText#' AND INP_NumInspecao ='#xml.rootelement.dados[1].RIP_NumInspecao.XmlText#'
</cfquery>

<cfif qVerificaInspecao.recordcount is 0>
	<cfquery datasource="#dsn_inspecao#">
	INSERT INTO Inspecao (INP_Unidade, INP_NumInspecao, INP_HrsPreInspecao, INP_DtInicDeslocamento, INP_DtFimDeslocamento, INP_HrsDeslocamento, INP_DtInicInspecao, INP_DtFimInspecao, INP_HrsInspecao, INP_Situacao, INP_DtEncerramento, INP_Coordenador, INP_Responsavel, INP_DtUltAtu, INP_UserName, INP_Motivo, INP_Modalidade) VALUES ('#xml.rootelement.dados[1].RIP_Unidade.XmlText#', '#xml.rootelement.dados[1].RIP_NumInspecao.XmlText#', '#xml.rootelement.dados[1].INP_HrsPreInspecao.XmlText#', CONVERT(DATETIME, '#xml.rootelement.dados[1].INP_DtInicDeslocamento.XmlText#', 103), CONVERT(DATETIME, '#xml.rootelement.dados[1].INP_DtFimDeslocamento.XmlText#', 103), '#xml.rootelement.dados[1].INP_HrsDeslocamento.XmlText#', CONVERT(DATETIME, '#xml.rootelement.dados[1].INP_DtInicInspecao.XmlText#', 103), CONVERT(DATETIME, '#xml.rootelement.dados[1].INP_DtFimInspecao.XmlText#', 103), '#xml.rootelement.dados[1].INP_HrsInspecao.XmlText#', 'CO', convert(char, getdate(), 102), '#xml.rootelement.dados[1].INP_Coordenador.XmlText#', '#xml.rootelement.dados[1].INP_Responsavel.XmlText#', CONVERT(char, GETDATE(), 120), '#xml.rootelement.dados[1].RIP_UserName.XmlText#', '#xml.rootelement.dados[1].INP_Motivo.XmlText#', '#inpModalidade#')
	</cfquery>
</cfif>
<!--- fim Insert Inspecao --->

<cfloop from="1" to="#ArrayLen(xml.rootelement.dados)#" index="i">
 <!--- <cftry>  --->
<!--- Insere dados com xml na tabela Resultado_Inspecao --->

<cfquery name="qVerificaResultado" datasource="#dsn_inspecao#">
SELECT RIP_NumInspecao
FROM Resultado_Inspecao
WHERE RIP_Unidade = '#xml.rootelement.dados[i].RIP_Unidade.XmlText#' AND RIP_NumInspecao = '#xml.rootelement.dados[i].RIP_NumInspecao.XmlText#' AND RIP_NumGrupo = #xml.rootelement.dados[i].RIP_NumGrupo.XmlText# AND RIP_NumItem = #xml.rootelement.dados[i].RIP_NumItem.XmlText#
</cfquery>

<cfif qVerificaResultado.recordcount is 0>
  <cfset strcomentario = xml.rootelement.dados[i].RIP_Comentario.XmlText>
    <cfset strcomentario = Replace(strcomentario,'"'," ",'All')>
	<cfset strcomentario = Replace(strcomentario,"'"," ","All")>
	<cfset strcomentario = Replace(strcomentario,'*'," ",'All')>
<!---	<cfset strcomentario = Replace(strcomentario,'&'," ",'All')>
	 <cfset strcomentario = Replace(strcomentario,'%'," ",'All')>  --->
	<!--- ================================= --->
  <cfset strrecomendacao = xml.rootelement.dados[i].RIP_Recomendacoes.XmlText>
    <cfset strrecomendacao = Replace(strrecomendacao,'"'," ",'All')>
	<cfset strrecomendacao = Replace(strrecomendacao,"'"," ","All")>
	<cfset strrecomendacao = Replace(strrecomendacao,'*'," ",'All')>
<!---	<cfset strrecomendacao = Replace(strrecomendacao,'&'," ",'All')>
	 <cfset strrecomendacao = Replace(strrecomendacao,'%'," ",'All')> --->
	 <cfset mFalta = Replace(xml.rootelement.dados[i].RIP_Falta.XmlText,',','.','All')>
	 <cfset mSobra = Replace(xml.rootelement.dados[i].RIP_Sobra.XmlText,',','.','All')>
	 <cfset mEmRisco = Replace(xml.rootelement.dados[i].RIP_EmRisco.XmlText,',','.','All')>
	 <cfset ReincInspecao = xml.rootelement.dados[i].RIP_ReincInspecao.XmlText>
     <cfset ReincGrupo = xml.rootelement.dados[i].RIP_ReincGrupo.XmlText>
	 <cfset ReincItem = xml.rootelement.dados[i].RIP_ReincItem.XmlText>
	 <cfset ripano =  right(xml.rootelement.dados[i].RIP_NumInspecao.XmlText,4)>
 	<cfquery datasource="#dsn_inspecao#">
	INSERT INTO Resultado_Inspecao (RIP_Unidade, RIP_NumInspecao, RIP_NumGrupo, RIP_NumItem, RIP_CodDiretoria, RIP_CodReop, RIP_Ano, RIP_Resposta, RIP_Comentario, RIP_DtUltAtu, RIP_UserName, RIP_Recomendacoes, RIP_Caractvlr, RIP_Falta, RIP_Sobra, RIP_EmRisco, RIP_ReincInspecao, RIP_ReincGrupo, RIP_ReincItem) 
	VALUES ('#xml.rootelement.dados[i].RIP_Unidade.XmlText#', '#xml.rootelement.dados[i].RIP_NumInspecao.XmlText#', #xml.rootelement.dados[i].RIP_NumGrupo.XmlText#, #xml.rootelement.dados[i].RIP_NumItem.XmlText#, '#xml.rootelement.dados[i].RIP_CodDiretoria.XmlText#', '#qVerificaTipoUnidade.Und_CodReop#', #ripano#, '#xml.rootelement.dados[i].RIP_Resposta.XmlText#', '#strcomentario#', CONVERT(char, GETDATE(), 120), '#xml.rootelement.dados[i].RIP_UserName.XmlText#', '#strrecomendacao#', '#xml.rootelement.dados[i].RIP_Caractvlr.XmlText#', '#mFalta#', '#mSobra#', '#mEmRisco#', '#ReincInspecao#', '#ReincGrupo#', '#ReincItem#')
	</cfquery>

<!---  <cfquery datasource="#dsn_inspecao#">
	INSERT INTO Resultado_Inspecao (RIP_Unidade, RIP_NumInspecao, RIP_NumGrupo, RIP_NumItem, RIP_CodDiretoria, RIP_CodReop, RIP_Ano, RIP_Resposta, RIP_Comentario, RIP_DtUltAtu, RIP_UserName, RIP_Recomendacoes, RIP_Caractvlr, RIP_Falta, RIP_Sobra, RIP_EmRisco) 
	VALUES ('#xml.rootelement.dados[i].RIP_Unidade.XmlText#', '#xml.rootelement.dados[i].RIP_NumInspecao.XmlText#', #xml.rootelement.dados[i].RIP_NumGrupo.XmlText#, #xml.rootelement.dados[i].RIP_NumItem.XmlText#, '#xml.rootelement.dados[i].RIP_CodDiretoria.XmlText#', '#qVerificaTipoUnidade.Und_CodReop#', #xml.rootelement.dados[i].RIP_Ano.XmlText#, '#xml.rootelement.dados[i].RIP_Resposta.XmlText#', '#strcomentario#', CONVERT(DATETIME, GETDATE(), 103), '#xml.rootelement.dados[i].RIP_UserName.XmlText#', '#strrecomendacao#', '#xml.rootelement.dados[i].RIP_Caractvlr.XmlText#', '#mFalta#', '#mSobra#', '#mEmRisco#')
	</cfquery> --->

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
   values ('#xml.rootelement.dados[i].RIP_Unidade.XmlText#', '#xml.rootelement.dados[i].RIP_NumInspecao.XmlText#', '#smatr#', CONVERT(DATETIME, '#xml.rootelement.dados[i].INP_DtInicInspecao.XmlText#', 103), CONVERT(DATETIME, '#xml.rootelement.dados[i].INP_DtFimInspecao.XmlText#', 103), CONVERT(DATETIME, '#xml.rootelement.dados[i].INP_DtInicDeslocamento.XmlText#', 103), CONVERT(DATETIME, '#xml.rootelement.dados[i].INP_DtFimDeslocamento.XmlText#', 103), '#snhpr#', '#snhde#', '#snhin#', CONVERT(char, '#xml.rootelement.dados[i].RIP_DtUltAtu.XmlText#', 120), '#xml.rootelement.dados[i].RIP_UserName.XmlText#')
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

<!---   <cfcatch type="database">
<!--- 	<cfoutput>#smatr#-#snhpr#-#snhde#-#snhin#</cfoutput>
<cfdump var="#cfcatch#">--->
<cfabort>
<script>alert('Ocorreu um erro durante esta operação! Favor verificar novamente os dados, ou contacte o administrador do sistema!'+'grupo'+#xml.rootelement.dados[i].RIP_NumGrupo.XmlText#+'item'+#xml.rootelement.dados[i].RIP_NumItem.XmlText#)</script>
<a href="" onClick="history.back()">Voltar para a página anterior</a>
<cfabort>
 </cfcatch>
 </cftry>   --->
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
     
	 <!--- Dado default para registro no campo Pos_Area --->
     <cfset posarea_cod = xml.rootelement.dados[i].RIP_Unidade.XmlText>
	 
	 <!--- Obter o tipo da Unidade e sua descrição para alimentar o Pos_AreaNome --->
     <cfquery name="rsUnid" datasource="#dsn_inspecao#">
		SELECT Und_Centraliza, Und_Descricao, Und_TipoUnidade FROM Unidades WHERE Und_Codigo = '#xml.rootelement.dados[i].RIP_Unidade.XmlText#'
	 </cfquery>
	 <!--- Dado default para registro no campo Pos_AreaNome --->
	 <cfset posarea_nome = rsUnid.Und_Descricao>
	 
	 <!--- Buscar o tipo de TipoUnidade que pertence a resposta do item --->
	 <cfquery name="rsItem" datasource="#dsn_inspecao#">
		SELECT Itn_TipoUnidade FROM Itens_Verificacao 
		WHERE (Itn_Ano = '#anoinsp#') and (Itn_NumGrupo = #xml.rootelement.dados[i].RIP_NumGrupo.XmlText#) AND (Itn_NumItem = #xml.rootelement.dados[i].RIP_NumItem.XmlText#)
	 </cfquery>
	 
	 <!--- Verificara possibilidade de alterar os dados default para Pos_Area e Pos_AreaNome ---> 
	 <cfif (trim(rsUnid.Und_Centraliza) neq "") and (rsItem.Itn_TipoUnidade eq 4)>
	    <!--- AC é Centralizada por CDD? --->
			<cfquery name="rsCDD" datasource="#dsn_inspecao#">
				SELECT Und_Descricao FROM Unidades WHERE Und_Codigo = '#rsUnid.Und_Centraliza#'
			</cfquery>
			<cfset posarea_cod = #rsUnid.Und_Centraliza#>
	        <cfset posarea_nome = #rsCDD.Und_Descricao#>
	 </cfif>
	<cfquery datasource="#dsn_inspecao#">
	 INSERT INTO ParecerUnidade (Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_NomeResp, Pos_Situacao, Pos_Parecer, Pos_co_ci, Pos_dtultatu, Pos_username, Pos_aval_dinsp, Pos_Situacao_Resp, Pos_Area, Pos_NomeArea) VALUES (
	'#xml.rootelement.dados[i].RIP_Unidade.XmlText#', '#xml.rootelement.dados[i].RIP_NumInspecao.XmlText#', #xml.rootelement.dados[i].RIP_NumGrupo.XmlText#, #xml.rootelement.dados[i].RIP_NumItem.XmlText#, CONVERT(char, GETDATE(), 102), '#CGI.REMOTE_USER#', 'RE', '', 'INTRANET', CONVERT(char, GETDATE(), 120), '#xml.rootelement.dados[i].RIP_UserName.XmlText#', NULL, 0, '#posarea_cod#', '#posarea_nome#')
	</cfquery>
<!---Fim Insere ParecerUnidade --->
 <cfset andparecer = #posarea_cod#  & " --- " & #posarea_nome#>
<!--- Inserindo dados dados na tabela Andamento --->
 <cfquery datasource="#dsn_inspecao#">
    insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, and_Parecer, And_Area) values ('#xml.rootelement.dados[i].RIP_NumInspecao.XmlText#', '#xml.rootelement.dados[i].RIP_Unidade.XmlText#', #xml.rootelement.dados[i].RIP_NumGrupo.XmlText#, #xml.rootelement.dados[i].RIP_NumItem.XmlText#, convert(char, getdate(), 102), '#CGI.REMOTE_USER#', 0, CONVERT(char, GETDATE(), 108), '#andparecer#', '#posarea_cod#')
 </cfquery>
 <!---Fim Insere Andamento --->

 <!--- Inserindo dados dados na tabela Analise --->
<!--- <cfquery datasource="#dsn_inspecao#">
    insert into Analise (Ana_NumInspecao, Ana_Unidade, Ana_NumGrupo, Ana_NumItem, Ana_Col01, Ana_Col02, Ana_Col03, Ana_Col04, Ana_Col05, Ana_Col06, Ana_Col07, Ana_Col08, Ana_Col09) values ('#xml.rootelement.dados[i].RIP_NumInspecao.XmlText#', '#xml.rootelement.dados[i].RIP_Unidade.XmlText#', #xml.rootelement.dados[i].RIP_NumGrupo.XmlText#, #xml.rootelement.dados[i].RIP_NumItem.XmlText#, '0', '0', '0', '0', '0', '0', '0', '0', '0')
</cfquery> --->
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
	  	<input type="button" class="botao" onClick="window.open('arquivo_dbins_transmitir.cfm?flush=true','_self')" value="Voltar">
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
	  	<input type="button" class="botao" onClick="window.open('arquivo_dbins_transmitir.cfm?flush=true','_self')" value="Voltar">
		&nbsp;&nbsp;&nbsp;
	    <input type="button" class="botao" onClick="window.close()" value="Sair">
	    </center></td>
    </tr>
</table>
</cfif>
</body>
</html>
<cfset sdtatual = dateformat(now(),"YYYYMMDDHH")>
<cfset sdtarquivo = dateformat(now(),"YYYYMMDDHH")>
<cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>
<cfset slocal = #diretorio# & 'Dados\'>  
<!--- <cfdirectory name="qList" filter="*.*" sort="name desc" directory="#slocal#"> --->
<cfdirectory name="qList" filter="*.*" sort="name asc" directory="#slocal#">
<cfoutput query="qList">
   <cfset sdtarquivo = dateformat(dateLastModified,"YYYYMMDDHH")> 
	   <cfif left(sdtatual,8) eq left(sdtarquivo,8)>
			<cfif (right(sdtatual,2) - right(sdtarquivo,2)) gte 2>
			   <cffile action="delete" file="#slocal##name#">  
			</cfif>
	  <cfelseif left(sdtatual,8) gt left(sdtarquivo,8)>
		<cffile action="delete" file="#slocal##name#">
	  </cfif>
<!--- 	 data atual: #sdtatual# -     Data do arquivo: #sdtarquivo#   nome do arquivo: #name#<br> --->
</cfoutput>