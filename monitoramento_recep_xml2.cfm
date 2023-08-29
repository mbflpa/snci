<cfprocessingdirective pageEncoding ="utf-8"/>

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

<!--- Se a quantidade de elementos no XML for diferente de 54 OU se a análise retornou registros rejeitados => exibir detalhes e abortar a inclusão do XML --->
<cfif (ArrayLen(xml.rootelement.dados) neq qtdItensInspecao) OR (arq_rej gt 0) OR (arq_inv gt 0)>
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
	<cfquery name="rsvlrelev" datasource="#dsn_inspecao#">
		SELECT VLR_Ano, VLR_Fator, VLR_FaixaInicial, VLR_FaixaFinal 
		FROM ValorRelevancia where VLR_Ano = '#right(xml.rootelement.dados[1].RIP_NumInspecao.XmlText,4)#'
	</cfquery>
	<cfset RIPPONTUADO = 0>
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
			 <cfset strrecomendacao = xml.rootelement.dados[i].RIP_Recomendacoes.XmlText>
			 <cfset mFalta = Replace(xml.rootelement.dados[i].RIP_Falta.XmlText,',','.','All')>
			 <cfset mSobra = Replace(xml.rootelement.dados[i].RIP_Sobra.XmlText,',','.','All')>
			 <cfset mEmRisco = Replace(xml.rootelement.dados[i].RIP_EmRisco.XmlText,',','.','All')>
			 <cfset ReincInspecao = xml.rootelement.dados[i].RIP_ReincInspecao.XmlText>
			 <cfset ReincGrupo = xml.rootelement.dados[i].RIP_ReincGrupo.XmlText>
			 <cfset ReincItem = xml.rootelement.dados[i].RIP_ReincItem.XmlText>
			 <cfset ripano =  right(xml.rootelement.dados[i].RIP_NumInspecao.XmlText,4)>
			<!---  <cfoutput>falta:#mFalta#<br></cfoutput> --->
			 <!--- Obter a pontuacao maxima --->
			 <cfset RIPPONTUACAO = xml.rootelement.dados[i].RIP_Pontuado.XmlText>
<!--- 			 <cfloop query="rsvlrelev">
			 	 <cfif (mFalta gt rsvlrelev.VLR_FaixaInicial) and (mFalta lte rsvlrelev.VLR_FaixaFinal)>
					 <cfset RIPPONTUACAO = (xml.rootelement.dados[i].RIP_Pontuado.XmlText) * rsvlrelev.VLR_Fator>		
					<!---  <cfoutput>#mFalta# #RIPPONTUACAO#  #rsvlrelev.VLR_Fator#<br></cfoutput>  --->
				 <cfelseif (rsvlrelev.VLR_FaixaFinal is '0.00') and (mFalta gt rsvlrelev.VLR_FaixaInicial)>
					 <cfset RIPPONTUACAO = (xml.rootelement.dados[i].RIP_Pontuado.XmlText) * rsvlrelev.VLR_Fator>		 
					 <!--- <cfoutput>#mFalta# #RIPPONTUACAO#  #rsvlrelev.VLR_Fator#<br></cfoutput>  --->
				 </cfif>
 			 </cfloop> --->
			 
			 <!--- obter a classificacao --->
	<!--- 		 <cfif RIPPONTUACAO gt 29>
				 <cfset RIPClassificacao = 'Grave'> 
			 <cfelseif RIPPONTUACAO gt 7 and RIPPONTUACAO lte 29>
				 <cfset RIPClassificacao = 'Mediana'> 
			 <cfelseif RIPPONTUACAO lte 7>
				 <cfset RIPClassificacao = 'Leve'> 
			 </cfif> --->
			 
			 <!--- <cfset RIPPONTUACAO = (RIPPONTUADO + xml.rootelement.dados[i].RIP_Pontuado.XmlText)> --->
			<cfquery datasource="#dsn_inspecao#">
			INSERT INTO Resultado_Inspecao (RIP_Unidade, RIP_NumInspecao, RIP_NumGrupo, RIP_NumItem, RIP_CodDiretoria, RIP_CodReop, RIP_Ano, RIP_Resposta, RIP_Comentario, RIP_DtUltAtu, RIP_UserName, RIP_Recomendacoes, RIP_Caractvlr, RIP_Falta, RIP_Sobra, RIP_EmRisco, RIP_ReincInspecao, RIP_ReincGrupo, RIP_ReincItem) 
			VALUES ('#xml.rootelement.dados[i].RIP_Unidade.XmlText#', '#xml.rootelement.dados[i].RIP_NumInspecao.XmlText#', #xml.rootelement.dados[i].RIP_NumGrupo.XmlText#, #xml.rootelement.dados[i].RIP_NumItem.XmlText#, '#xml.rootelement.dados[i].RIP_CodDiretoria.XmlText#', '#qVerificaTipoUnidade.Und_CodReop#', #ripano#, '#xml.rootelement.dados[i].RIP_Resposta.XmlText#', '#strcomentario#', CONVERT(char, GETDATE(), 120), '#xml.rootelement.dados[i].RIP_UserName.XmlText#', '#strrecomendacao#', '#xml.rootelement.dados[i].RIP_Caractvlr.XmlText#', '#mFalta#', '#mSobra#', '#mEmRisco#', '#ReincInspecao#', '#ReincGrupo#', '#ReincItem#')
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
	
		<!--- 		<cfquery datasource="#dsn_inspecao#">
				   insert into Inspetor_Inspecao (IPT_CodUnidade, IPT_NumInspecao, IPT_MatricInspetor, IPT_DtInicInsp, IPT_DtFimInsp, IPT_DtInicDesloc, IPT_DtFimDesloc, IPT_NumHrsPreInsp, IPT_NumHrsdesloc, IPT_NumHrsInsp, IPT_DtUltAtu, IPT_UserName)
				   values ('#xml.rootelement.dados[i].RIP_Unidade.XmlText#', '#xml.rootelement.dados[i].RIP_NumInspecao.XmlText#', '#smatr#', CONVERT(DATETIME, '#xml.rootelement.dados[i].INP_DtInicInspecao.XmlText#', 103), CONVERT(DATETIME, '#xml.rootelement.dados[i].INP_DtFimInspecao.XmlText#', 103), CONVERT(DATETIME, '#xml.rootelement.dados[i].INP_DtInicDeslocamento.XmlText#', 103), CONVERT(DATETIME, '#xml.rootelement.dados[i].INP_DtFimDeslocamento.XmlText#', 103), '#snhpr#', '#snhde#', '#snhin#', CONVERT(DATETIME, '#xml.rootelement.dados[i].RIP_DtUltAtu.XmlText#', 103), '#xml.rootelement.dados[i].RIP_UserName.XmlText#')
				</cfquery> --->
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

</cfloop>
<!--- Fim Insere Resultado_Inspecao --->

<!--- Insere dados com xml na tabela Inspecao --->
<cfquery name="qVerificaInspecao" datasource="#dsn_inspecao#">
SELECT INP_NumInspecao
FROM Inspecao
WHERE INP_Unidade = '#xml.rootelement.dados[1].RIP_Unidade.XmlText#' AND INP_NumInspecao ='#xml.rootelement.dados[1].RIP_NumInspecao.XmlText#'
</cfquery>

<cfif qVerificaInspecao.recordcount is 0>
	<cfquery datasource="#dsn_inspecao#">
	INSERT INTO Inspecao (INP_Unidade, INP_NumInspecao, INP_HrsPreInspecao, INP_DtInicDeslocamento, INP_DtFimDeslocamento, INP_HrsDeslocamento, INP_DtInicInspecao, INP_DtFimInspecao, INP_HrsInspecao, INP_Situacao, INP_DtEncerramento, INP_Coordenador, INP_Responsavel, INP_DtUltAtu, INP_UserName, INP_Motivo, INP_Modalidade) VALUES ('#xml.rootelement.dados[1].RIP_Unidade.XmlText#', '#xml.rootelement.dados[1].RIP_NumInspecao.XmlText#', '#xml.rootelement.dados[1].INP_HrsPreInspecao.XmlText#', CONVERT(DATETIME, '#xml.rootelement.dados[1].INP_DtInicDeslocamento.XmlText#', 103), CONVERT(DATETIME, '#xml.rootelement.dados[1].INP_DtFimDeslocamento.XmlText#', 103), '#xml.rootelement.dados[1].INP_HrsDeslocamento.XmlText#', CONVERT(DATETIME, '#xml.rootelement.dados[1].INP_DtInicInspecao.XmlText#', 103), CONVERT(DATETIME, '#xml.rootelement.dados[1].INP_DtFimInspecao.XmlText#', 103), '#xml.rootelement.dados[1].INP_HrsInspecao.XmlText#', 'CO', convert(char, getdate(), 102), '85053732', '#xml.rootelement.dados[1].INP_Responsavel.XmlText#', CONVERT(char, GETDATE(), 120), '#xml.rootelement.dados[1].RIP_UserName.XmlText#', '#xml.rootelement.dados[1].INP_Motivo.XmlText#', '#inpModalidade#')
	</cfquery>
</cfif> 
<!--- fim Insert Inspecao --->
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