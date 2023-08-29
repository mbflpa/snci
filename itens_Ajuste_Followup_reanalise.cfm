<cfprocessingdirective pageEncoding ="utf-8"/>

<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	<cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>   

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_DR, RTRIM(LTRIM(Usu_GrupoAcesso)) AS Usu_GrupoAcesso, Usu_Matricula, Usu_Email, Usu_Apelido, Usu_Coordena 
	from usuarios 
	where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>


<cfif isDefined("Form.recomendacao")>
  <cfparam name="Form.recomendacao" default="#form.recomendacao#">
  <cfparam name="URL.pg" default="#form.pg#">
  <cfparam name="URL.Ninsp" default="#trim(Form.Ninsp)#">
  <cfparam name="URL.Ngrup" default="#trim(Form.Ngrup)#">
  <cfparam name="URL.Nitem" default="#trim(Form.Nitem)#">
<cfelse>
   <cfparam name="Form.recomendacao" default="">
   <cfparam name="URL.Ninsp" default="">
   <cfparam name="URL.Ngrup" default="">
   <cfparam name="URL.Nitem" default="">
   <cfparam name="URL.pg" default="">
</cfif>

<cfquery name="qOrientacao" datasource="#dsn_inspecao#">
	SELECT RIP_Recomendacao_Inspetor, RIP_Critica_Inspetor, RIP_Recomendacao, RIP_Resposta, INP_Modalidade, Und_TipoUnidade FROM Resultado_Inspecao
	INNER JOIN Inspecao ON INP_NumInspecao = RIP_NumInspecao
	INNER JOIN Unidades ON RIP_Unidade = Und_Codigo
	WHERE RIP_NumInspecao = '#URL.Ninsp#' and RIP_NumGrupo='#url.Ngrup#' and RIP_NumItem ='#url.Nitem#'
</cfquery>

<cfparam name="url.tpunid" default="#qOrientacao.Und_TipoUnidade#">

<cfquery name="qItemReanalise" datasource="#dsn_inspecao#">
	SELECT * FROM Itens_Verificacao
	INNER JOIN Grupos_Verificacao ON Itn_NumGrupo = Grp_Codigo and Grp_Ano = Itn_Ano
	WHERE Itn_Ano=RIGHT('#URL.Ninsp#',4) AND Grp_Ano=Itn_Ano and Itn_NumGrupo='#url.Ngrup#' and Itn_NumItem ='#url.Nitem#' and Itn_TipoUnidade = #url.tpunid# and Itn_Modalidade = '#qOrientacao.INP_Modalidade#'
</cfquery>

<cfquery name="qUltimoReavaliado" datasource="#dsn_inspecao#">
	SELECT RIP_Recomendacao_Inspetor, RIP_Critica_Inspetor, RIP_Recomendacao FROM Resultado_Inspecao
	WHERE RIP_NumInspecao = '#URL.Ninsp#' AND RIP_Recomendacao = 'R'
</cfquery>
<cfif isDefined("Form.acao") and "#form.acao#" eq 'cancelarReanalise'>
		<!---Veirifica se esta inspeção possui algum item em reanálise --->
		<cfquery datasource="#dsn_inspecao#" name="qVerifEmReanalise">
			SELECT RIP_Resposta, RIP_Recomendacao FROM Resultado_Inspecao 
			WHERE (RIP_Recomendacao='S' OR RIP_Recomendacao='R') and RIP_NumInspecao='#ninsp#'  
		</cfquery>
		<cfif qVerifEmReanalise.recordCount eq 0>
			<!--- Update na tabela Inspecao com sigla  NA = não avaliada, ER = em reavaliação, RA = reavaliada, CO = concluída--->
			<cfquery datasource="#dsn_inspecao#">
				UPDATE Inspecao set INP_Situacao ='CO'
				WHERE INP_NumInspecao = '#URL.Ninsp#' 
			</cfquery>
		</cfif>
		<!--- Update na tabela Resultado_Inspecao--->
		<cfquery datasource="#dsn_inspecao#">
			UPDATE Resultado_Inspecao set 
				RIP_Recomendacao = '', RIP_Critica_Inspetor='#form.respInsp#'
			WHERE RIP_NumInspecao = '#URL.Ninsp#' and RIP_NumGrupo ='#url.Ngrup#' and RIP_NumItem ='#url.Nitem#'
		</cfquery>
			
		<cfquery datasource="#dsn_inspecao#" name="rsVerificaItem">
			SELECT  RIP_Resposta, RIP_Unidade, RIP_NCISEI, RIP_Falta, RIP_Sobra, RIP_REINCINSPECAO FROM Resultado_Inspecao 
			WHERE RIP_NumInspecao='#FORM.Ninsp#' And RIP_NumGrupo = '#FORM.Ngrup#' and RIP_NumItem ='#FORM.Nitem#' 
		</cfquery>
		<cfparam name="FORM.unid" default="#rsVerificaItem.RIP_Unidade#">
		
		<!--- Dado default para registro no campo Pos_Area --->
		<cfset posarea_cod = '#FORM.unid#'>	
		<!--- Obter o tipo da Unidade e sua descrição para alimentar o Pos_AreaNome --->
		<cfquery name="rsUnid" datasource="#dsn_inspecao#">
			SELECT Und_Centraliza, Und_Descricao, Und_TipoUnidade FROM Unidades WHERE Und_Codigo = '#FORM.unid#'
		</cfquery>
		<!--- Dado default para registro no campo Pos_AreaNome --->
		<cfset posarea_nome = rsUnid.Und_Descricao>
		<!--- Buscar o tipo de TipoUnidade que pertence a resposta do item --->
		<cfquery name="rsItem2" datasource="#dsn_inspecao#">
			SELECT Itn_TipoUnidade, Itn_Pontuacao, Itn_Classificacao, Itn_PTC_Seq
			FROM Itens_Verificacao 
			WHERE (Itn_Ano = right('#FORM.Ninsp#',4)) and (Itn_NumGrupo = '#FORM.Ngrup#') AND (Itn_NumItem = '#FORM.Nitem#') and (Itn_TipoUnidade = #url.tpunid#) and (Itn_Modalidade = '#qItemReanalise.Itn_Modalidade#')
		</cfquery>
		<!--- Verificara possibilidade de alterar os dados default para Pos_Area e Pos_AreaNome ---> 
		<cfif (trim(rsUnid.Und_Centraliza) neq "") and (rsItem2.Itn_TipoUnidade eq 4)>
			<!--- AC é Centralizada por CDD? --->
			<cfquery name="rsCDD" datasource="#dsn_inspecao#">
				SELECT Und_Descricao FROM Unidades WHERE Und_Codigo = '#rsUnid.Und_Centraliza#'
			</cfquery>
			<cfset posarea_cod = #rsUnid.Und_Centraliza#>
			<cfset posarea_nome = #rsCDD.Und_Descricao#>
		</cfif>
		<!--- Se a valição for não conforme, iniciar um insert na tabela parecer unidade --->
		<cfif '#rsVerificaItem.RIP_Resposta#' eq 'N'>
<!--- inicio classificacao do ponto --->
			<cfset composic = rsItem2.Itn_PTC_Seq>	
			<cfset ItnPontuacao = rsItem2.Itn_Pontuacao>
			<cfset ClasItem_Ponto = ucase(trim(rsitem2.Itn_Classificacao))>
			 <cfset somafaltasobra=0>
					
			<cfset impactosn = 'N'>
			<cfif left(composic,2) eq '10'>
				<cfset impactosn = 'S'>
			</cfif>
			<cfset fator = 1>
		
			<cfif impactosn eq 'S'>
				<cfquery name="rsRelev" datasource="#dsn_inspecao#">
					SELECT VLR_Fator, VLR_FaixaInicial, VLR_FaixaFinal
					FROM ValorRelevancia
					WHERE VLR_Ano = right('#FORM.Ninsp#',4))
				</cfquery
				 <cfset somafaltasobra = rsVerificaItem.RIP_Falta>
				 <cfif (FORM.Nitem eq 1 and (FORM.Ngrup eq 53 or FORM.Ngrup eq 72 or FORM.Ngrup eq 214 or FORM.Ngrup eq 284))>
					<cfset somafaltasobra = somafaltasobra + rsVerificaItem.RIP_Sobra>
				 </cfif>
				 <cfif somafaltasobra gt 0>
					<cfloop query="rsRelev">
						 <cfif rsRelev.VLR_FaixaInicial is 0 and rsRelev.VLR_FaixaFinal lte somafaltasobra>
							<cfset fator = rsRelev.VLR_Fator>
						 <cfelseif rsRelev.VLR_FaixaInicial neq 0 and VLR_FaixaFinal neq 0 and somafaltasobra gt rsRelev.VLR_FaixaInicial and somafaltasobra lte rsRelev.VLR_FaixaFinal>
							<cfset fator = rsRelev.VLR_Fator>									
						 <cfelseif VLR_FaixaFinal eq 0 and somafaltasobra gt rsRelev.VLR_FaixaInicial>
							<cfset fator = rsRelev.VLR_Fator> 								
						 </cfif>
					</cfloop>
				</cfif>	
			</cfif>	
			<cfset ItnPontuacao =  (ItnPontuacao * fator)>	
			<cfif impactosn eq 'S'>
					<!--- Ajustes para os campos: Pos_ClassificacaoPonto --->
					<!--- Obter a pontuacao max pelo ano e tipo da unidade --->
					<cfquery name="rsPtoMax" datasource="#dsn_inspecao#">
						SELECT TUP_PontuacaoMaxima 
						FROM Tipo_Unidade_Pontuacao 
						WHERE TUP_Ano = '#right(url.numInspecao,4)#' AND TUP_Tun_Codigo = #rsItem2.Itn_TipoUnidade#
					</cfquery> 
					<!--- calcular o perc de classificacao do item --->	
					<cfset PercClassifPonto = NumberFormat(((ItnPontuacao / rsPtoMax.TUP_PontuacaoMaxima) * 100),999.00)>	
					
					<!--- calculo da descricao do item a saber GRAVE, MEDIANO ou LEVE --->
					
					<cfif PercClassifPonto gt 50.01>
					<cfset ClasItem_Ponto = 'GRAVE'> 
					<cfelseif PercClassifPonto gt 10 and PercClassifPonto lte 50.01>
					<cfset ClasItem_Ponto = 'MEDIANO'> 
					<cfelseif PercClassifPonto lte 10>
					<cfset ClasItem_Ponto = 'LEVE'> 
					</cfif>	
			</cfif>	
			<cfif ClasItem_Ponto eq 'LEVE'	and len(trim(rsVerificaItem.RIP_REINCINSPECAO)) gt 0>
			      <cfset ClasItem_Ponto = 'MEDIANO'>
			</cfif>				
	<!--- fim classificacao do ponto --->	
			<cfquery datasource="#dsn_inspecao#">
				INSERT INTO ParecerUnidade (Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_NomeResp, Pos_Situacao, Pos_Parecer, Pos_co_ci, Pos_dtultatu, Pos_username, Pos_aval_dinsp, Pos_Situacao_Resp, Pos_Area, Pos_NomeArea, Pos_NCISEI, Pos_PontuacaoPonto, Pos_ClassificacaoPonto) 
				VALUES ('#FORM.unid#', '#FORM.Ninsp#', #FORM.Ngrup#, #FORM.Nitem#, 
						CONVERT(char, GETDATE(), 102), '#CGI.REMOTE_USER#', 'RE', '', 'INTRANET', CONVERT(char, GETDATE(), 120), '#CGI.REMOTE_USER#', NULL, 0,
						'#posarea_cod#','#posarea_nome#','#rsVerificaItem.RIP_NCISEI#', #ItnPontuacao#,'#ClasItem_Ponto#')
			</cfquery>
			<!---Fim Insere ParecerUnidade --->
		
			<!--- Inserindo dados dados na tabela Andamento --->
			<cfset andparecer = #posarea_cod#  & " --- " & #posarea_nome#>
			<cfquery datasource="#dsn_inspecao#">
				insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, and_Parecer, And_Area) 
				values ('#FORM.Ninsp#', '#FORM.unid#', #FORM.Ngrup#, #FORM.Nitem#, convert(char, getdate(), 102), '#CGI.REMOTE_USER#', 0, CONVERT(char, GETDATE(), 108), '#andparecer#', '#posarea_cod#')
			</cfquery>
			<!---Fim Insere Andamento --->
		</cfif> 


		<!---Início do processo de liberação da avaliação--->
			<!---Veirifica se esta inspeção possui algum item Em Revisão --->	
			<cfquery name="qInspecaoLiberada" datasource="#dsn_inspecao#">
				SELECT * FROM ParecerUnidade 
				WHERE Pos_Inspecao='#ninsp#' AND Pos_Situacao_Resp = 0
			</cfquery>
			<!---Veirifica se esta inspeção possui algum item em reanálise --->
			<cfquery datasource="#dsn_inspecao#" name="qVerifEmReanalise">
				SELECT RIP_Resposta, RIP_Recomendacao FROM Resultado_Inspecao 
				WHERE (RIP_Recomendacao='S' OR RIP_Recomendacao='R') and RIP_NumInspecao='#ninsp#'  
			</cfquery>
			<!---Verifica se esta inspeção possui algum item não avaliado (todos os NÃO VERIFICADO e os NÂO EXECUTA em que o campo Itn_ValidacaoObrigatoria for igual a 1) --->
			<cfquery datasource="#dsn_inspecao#" name="qVerifValidados">
				SELECT RIP_Resposta, RIP_Recomendacao,Itn_ValidacaoObrigatoria 
				FROM Resultado_Inspecao 
					INNER JOIN Unidades ON 
					RIP_Unidade = Und_Codigo
					INNER JOIN Inspecao ON 
					RIP_NumInspecao = INP_NumInspecao AND RIP_Unidade = INP_Unidade
				INNER JOIN Itens_Verificacao ON 
				Itn_Ano = convert(char(4),RIP_Ano) AND 
				INP_Modalidade = Itn_Modalidade AND
				Itn_TipoUnidade = Und_TipoUnidade and
				Itn_NumGrupo = RIP_NumGrupo AND 
				Itn_NumItem = RIP_NumItem 
				WHERE ((RTRIM(RIP_Resposta)= 'E' AND Itn_ValidacaoObrigatoria=1) OR RTRIM(RIP_Resposta)= 'V') 
				AND RTRIM(RIP_Recomendacao) IS NULL AND RIP_NumInspecao='#ninsp#' AND Itn_TipoUnidade = #url.tpunid#			 
			</cfquery>

			<!---Início - Se não existirem itens em revisão e não existirem itens em reavaliação,e nao existirem itens a serem validados,
				inicia o processo de liberação de todos os itens--->	
				<cfif qInspecaoLiberada.recordCount eq 0 and qVerifEmReanalise.recordCount eq 0 and qVerifValidados.recordCount eq 0>
					<!---Salva a matricula do gestor na tabela Inspecao para sinalisar o gestor que liberou a verificação --->
					<cfquery datasource="#dsn_inspecao#">
						UPDATE Inspecao SET INP_Situacao = 'CO', INP_UserName = '#qAcesso.Usu_Matricula#', INP_DTUltAtu = CONVERT(char, getdate(), 120)
						WHERE INP_Unidade = '#FORM.unid#' and INP_NumInspecao ='#ninsp#'
					</cfquery>
					
					<cfquery name="rs11" datasource="#dsn_inspecao#">
						SELECT Und_TipoUnidade, Und_Centraliza, Itn_TipoUnidade, Itn_PTC_Seq, Itn_Pontuacao, Itn_Classificacao, Pos_Unidade, Pos_NumGrupo, Pos_NumItem, Pos_Area, Pos_NomeArea, Pos_Situacao_Resp
						FROM Itens_Verificacao 
						INNER JOIN (ParecerUnidade 
						INNER JOIN Inspecao ON Pos_Inspecao = INP_NumInspecao AND Pos_Unidade = INP_Unidade
						INNER JOIN Unidades ON Pos_Unidade = Und_Codigo) ON (INP_Modalidade = Itn_Modalidade and Itn_Ano = #right(ninsp,4)# and 
						Itn_TipoUnidade = Und_TipoUnidade and Itn_NumItem = Pos_NumItem) AND (Itn_NumGrupo = Pos_NumGrupo) 
						WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#ninsp#' AND (Itn_TipoUnidade = #url.tpunid#) AND Pos_Situacao_Resp = 11
					</cfquery> 
					
					<!--- inicio 10 (dez) dias uteis para status 14-NR --->
					<cfif rs11.recordcount gt 0>
						<cfquery name="rsRelev" datasource="#dsn_inspecao#">
							SELECT VLR_Fator, VLR_FaixaInicial, VLR_FaixaFinal
							FROM ValorRelevancia
							WHERE VLR_Ano = right('#ninsp#',4))
						</cfquery
						
						<cfset auxdtprev = CreateDate(year(now()),month(now()),day(now()))>
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
					</cfif>
					<!--- fim 10 (dez) dias uteis para status 14-NR --->

					<!---Início -Se existirem itens em liberação, executa a rotina para mudança do status de todos os itens
						em liberação para não respondido--->
						<cfloop query="rs11">
							<cfset auxposarea = rs11.Pos_Area>
							<cfset auxnomearea = rs11.Pos_NomeArea>
							
							<cfif (rs11.Und_Centraliza neq "") and (rs11.Itn_TipoUnidade eq 4)>
									<cfquery name="rsCDD" datasource="#dsn_inspecao#">
									SELECT Und_Descricao FROM Unidades WHERE Und_Codigo = '#rs11.Und_Centraliza#'
									</cfquery>
									<cfset auxposarea = rs11.Und_Centraliza>
									<cfset auxnomearea = rsCDD.Und_Descricao>
							</cfif>
					<!--- inicio classificacao do ponto --->
							<cfquery name="rsInspecaoFinal" datasource="#dsn_inspecao#">
								SELECT * FROM Resultado_Inspecao 
								INNER JOIN Inspecao ON (RIP_NumInspecao = INP_NumInspecao) AND (RIP_Unidade =INP_Unidade) 
								WHERE RIP_NumInspecao='#ninsp#' and RIP_NumGrupo=#rs11.Pos_NumGrupo# and RIP_NumItem=#rs11.Pos_NumItem#
							</cfquery>					
							<cfset composic = rs11.Itn_PTC_Seq>	
							<cfset ItnPontuacao = rs11.Itn_Pontuacao>
							<cfset ClasItem_Ponto = ucase(trim(rs11.Itn_Classificacao))>
							 <cfset somafaltasobra=0>
									
							<cfset impactosn = 'N'>
							<cfif left(composic,2) eq '10'>
								<cfset impactosn = 'S'>
							</cfif>
							<cfset fator = 1>
						
							<cfif impactosn eq 'S'>
								 <cfset somafaltasobra = rsInspecaoFinal.RIP_Falta>
								 <cfif (rs11.Pos_NumItem eq 1 and (rs11.Pos_NumGrupo eq 53 or rs11.Pos_NumGrupo eq 72 or rs11.Pos_NumGrupo eq 214 or rs11.Pos_NumGrupo eq 284))>
									<cfset somafaltasobra = somafaltasobra + rsInspecaoFinal.RIP_Sobra>
								 </cfif>
								 <cfif somafaltasobra gt 0>
									<cfloop query="rsRelev">
										 <cfif rsRelev.VLR_FaixaInicial is 0 and rsRelev.VLR_FaixaFinal lte somafaltasobra>
											<cfset fator = rsRelev.VLR_Fator>
										 <cfelseif rsRelev.VLR_FaixaInicial neq 0 and VLR_FaixaFinal neq 0 and somafaltasobra gt rsRelev.VLR_FaixaInicial and somafaltasobra lte rsRelev.VLR_FaixaFinal>
											<cfset fator = rsRelev.VLR_Fator>									
										 <cfelseif VLR_FaixaFinal eq 0 and somafaltasobra gt rsRelev.VLR_FaixaInicial>
											<cfset fator = rsRelev.VLR_Fator> 								
										 </cfif>
									</cfloop>
								</cfif>	
							</cfif>	
							<cfset ItnPontuacao =  (ItnPontuacao * fator)>	
							<cfif impactosn eq 'S'>
									<!--- Ajustes para os campos: Pos_ClassificacaoPonto --->
									<!--- Obter a pontuacao max pelo ano e tipo da unidade --->
									<cfquery name="rsPtoMax" datasource="#dsn_inspecao#">
										SELECT TUP_PontuacaoMaxima 
										FROM Tipo_Unidade_Pontuacao 
										WHERE TUP_Ano = '#right(ninsp,4)#' AND TUP_Tun_Codigo = #rs11.Itn_TipoUnidade#
									</cfquery> 
									<!--- calcular o perc de classificacao do item --->	
									<cfset PercClassifPonto = NumberFormat(((ItnPontuacao / rsPtoMax.TUP_PontuacaoMaxima) * 100),999.00)>	
									
									<!--- calculo da descricao do item a saber GRAVE, MEDIANO ou LEVE --->
									
									<cfif PercClassifPonto gt 50.01>
									<cfset ClasItem_Ponto = 'GRAVE'> 
									<cfelseif PercClassifPonto gt 10 and PercClassifPonto lte 50.01>
									<cfset ClasItem_Ponto = 'MEDIANO'> 
									<cfelseif PercClassifPonto lte 10>
									<cfset ClasItem_Ponto = 'LEVE'> 
									</cfif>	
							</cfif>	
							<cfif ClasItem_Ponto eq 'LEVE'	and len(trim(rsInspecaoFinal.RIP_REINCINSPECAO)) gt 0>
								  <cfset ClasItem_Ponto = 'MEDIANO'>
							</cfif>				
					    <!--- fim classificacao do ponto --->							
							<!---Update na tabela parecer unidade--->
							<cfquery datasource="#dsn_inspecao#">
								UPDATE ParecerUnidade SET Pos_Area = '#auxposarea#'
								, Pos_NomeArea = '#auxnomearea#'
								, Pos_Situacao_Resp = 14
								, Pos_Situacao = 'NR'
								, Pos_DtPosic = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#
								, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(auxdtprev),month(auxdtprev),day(auxdtprev)))#
								, Pos_DtUltAtu = CONVERT(char, GETDATE(), 120) 
								, pos_username = '#CGI.REMOTE_USER#'
								, Pos_Sit_Resp_Antes = #rs11.Pos_Situacao_Resp#
								, Pos_PontuacaoPonto = #ItnPontuacao#
								, Pos_ClassificacaoPonto='#ClasItem_Ponto#'
								WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#ninsp#' and Pos_NumGrupo = #rs11.Pos_NumGrupo# and Pos_NumItem = #rs11.Pos_NumItem# and Pos_Situacao_Resp = 11
							</cfquery>
							
						</cfloop>
					<!---Fim -Se existirem itens em liberação, executa a rotina para mudança do status de todos os itens
						em liberação para não respondido--->

					<!--- Início - e-mail automático por unidade --->
						<cfquery name="rsEmail" datasource="#dsn_inspecao#">
							SELECT Pos_Area, Pos_NomeArea, Pos_Unidade, Und_TipoUnidade, Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Und_CodReop, INP_DtInicInspecao
							FROM Inspecao INNER JOIN (Unidades INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade) ON (INP_NumInspecao = Pos_Inspecao) AND (INP_Unidade = Pos_Unidade)
							WHERE (Pos_Unidade = '#FORM.unid#') AND (Pos_Inspecao = '#ninsp#') AND (Pos_Situacao_Resp = 14)
						</cfquery>

						<cfoutput>
							<cfset emailunid = "">
							<cfset emailreopunid = "">
							<cfset emailcdd = "">
							<cfset emailreopcdd = "">

							<cfif rsEmail.recordcount gt 0>
								<!--- Busca de email da Unidade --->
								<cfloop query="rsEmail">
									<cfif rsEmail.Pos_Area eq rsEmail.Pos_Unidade and emailunid eq "">
									<!--- adquirir o email dos registro do Pos_Area --->
										<cfquery name="rsPosUnidEmail" datasource="#dsn_inspecao#">
										SELECT Und_Descricao, Und_Email FROM Unidades WHERE Und_Codigo = '#rsEmail.Pos_Unidade#'
										</cfquery>
										<cfset emailunid = #rsPosUnidEmail.Und_Email#>
										<!--- adquirir o email do OrgaoSubordiador --->
										<cfquery name="rsReopunidEmail" datasource="#dsn_inspecao#">
										SELECT Rep_Email FROM Reops WHERE Rep_Codigo = '#rsEmail.Pos_Unidade#'
										</cfquery>
										<cfset emailreopunid = #rsReopunidEmail.Rep_Email# >
									</cfif>
									<!--- Busca de email do CDD --->
									<cfif rsEmail.Pos_Area neq rsEmail.Pos_Unidade and emailcdd eq "">
									<!--- adquirir o email dos registro do Pos_Area --->
										<cfquery name="rsPosAreaEmail" datasource="#dsn_inspecao#">
										SELECT Und_Descricao, Und_Email FROM Unidades WHERE Und_Codigo = '#rsEmail.Pos_Area#'
										</cfquery>
										<cfset emailcdd = #rsPosAreaEmail.Und_Email#>

										<!--- adquirir o email do OrgaoSubordiador --->
										<cfquery name="rsReopcddEmail" datasource="#dsn_inspecao#">
										SELECT Rep_Email FROM Reops WHERE Rep_Codigo = '#rsEmail.Pos_Area#'
										</cfquery>
										<cfset emailreopcdd = #rsReopcddEmail.Rep_Email# >
									</cfif>
								</cfloop>

								<cfset sdestina = "">
								<cfif emailunid neq "">
								<cfset sdestina = #sdestina# & ';' & #emailunid#>
								</cfif>

								<cfif emailreopunid neq "">
								<cfset sdestina = #sdestina# & ';' & #emailreopunid#>
								</cfif>

								<cfif emailcdd neq "">
								<cfset sdestina = #sdestina# & ';' & #emailcdd#>
								</cfif>

								<cfif emailreopcdd neq "">
								<cfset sdestina = #sdestina# & ';' & #emailreopcdd#>
								</cfif>

								<cfif findoneof("@", trim(sdestina)) eq 0>
									<cfset sdestina = "gilvanm@correios.com.br">
								</cfif>

									<!--- adquirir o email do SCOI da SE --->
									<cfquery name="rsSCOIEmail" datasource="#dsn_inspecao#">
										SELECT Ars_Email
										FROM Areas
										WHERE (Ars_Codigo Like 'left(#ninsp#,2)%') AND 
										(Ars_Sigla Like '%CCOP/SCOI%' OR Ars_Sigla Like '%DCINT/GCOP/SGCIN/SCOI') AND (Ars_Status='A')
									</cfquery>
								<cfset assunto = 'Relatório de Controle Interno - ' & #trim(rsEmail.Und_Descricao)# & ' - Avaliação de Controle Interno ' & #ninsp#>
								<cfmail from="SNCI@correios.com.br" to="#sdestina#" subject="#assunto#" type="HTML">
									Mensagem automática. Não precisa responder!<br><br>
									<strong>
									Prezado(a) Gerente do(a) #trim(Ucase(rsEmail.Und_Descricao))#, informamos que estão disponível na intranet o Relatório de Controle Interno: N° #ninsp#, realizada nessa Unidade na Data: #dateformat(rsEmail.INP_DtInicInspecao,"dd/mm/yyyy")#. <br><br><br>

								&nbsp;&nbsp;&nbsp;Solicitamos acessá-lo para registro de sua resposta, conforme orientações a seguir:<br><br>

								&nbsp;&nbsp;&nbsp;a) Informar a Justificativa para ocorrência da falha: o que ocasionou o Problema (CAUSA); <br>

								&nbsp;&nbsp;&nbsp;b) Informar o Plano de Ações adotado para regularização da falha detectada, com prazo de implementação;<br>

								&nbsp;&nbsp;&nbsp;c) Anexar no sistema os Comprovantes de regularização da situação encontrada e/ou das Ações implementadas (em PDF).<br><br>

								&nbsp;&nbsp;&nbsp;Registrar a resposta no Sistema Nacional de Controle Interno - SNCI  num prazo de dez (10) dias úteis, contados a partir da data de entrega do Relatório. <br>
								&nbsp;&nbsp;&nbsp;O Não cumprimento desse prazo ensejará comunicação ao órgão subordinador dessa unidade.<br><br>

								&nbsp;&nbsp;&nbsp;Acesse o SNCI clicando no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">Relatório de Controle Interno.</a><br><br>

								&nbsp;&nbsp;&nbsp;Atentar para as orientações deste e-mail para registro de sua manifestação no SNCI. Respostas incompletas serão devolvidas para complementação. <br><br>

								&nbsp;&nbsp;&nbsp;Em caso de dúvidas, entrar em contato com a Equipe de Controle Interno localizada na SE, por meio do endereço eletrônico:  #rsSCOIEmail.Ars_Email#.<br><br>

								<table>
								<tr>
								<td><strong>Unidade : #rsEmail.Pos_Unidade# - #rsEmail.Und_Descricao#</strong></td>
								</tr>
								<tr>
								<td><strong>Inspeção: #rsEmail.Pos_Inspecao#</strong></td>
								</tr>
								<tr>
								<td><strong>------------------------------------------</strong></td>
								</tr>
								</table>
								<br>
								&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
								</strong>
								</cfmail>
							</cfif>
						</cfoutput>
					<!--- Fim - e-mail automático por unidade --->
				</cfif>
			<!---Fim do processo de liberação de todos os itens--->	
			<!--- Início Verificação dos registros que estão na situação 14(Não Respondido) na tabela ParecerUnidade --->
				<cfquery name="qNaoRespondido" datasource="#dsn_inspecao#">
					SELECT Pos_Inspecao, Pos_Unidade, Pos_NumGrupo, Pos_NumItem, Pos_Situacao_Resp FROM ParecerUnidade
					WHERE Pos_Inspecao='#ninsp#' AND Pos_Situacao_Resp = 14
				</cfquery>
				
				<cfoutput query="qNaoRespondido">
					<cfquery name="rs14SN" datasource="#dsn_inspecao#">
						SELECT And_NumInspecao FROM Andamento
						WHERE And_Unidade='#qNaoRespondido.Pos_Unidade#' AND And_NumInspecao='#qNaoRespondido.Pos_Inspecao#' AND And_NumGrupo=#qNaoRespondido.Pos_NumGrupo# AND And_NumItem=#qNaoRespondido.Pos_NumItem# 
						AND And_Situacao_Resp = 14
					</cfquery> 
					
					<cfif qNaoRespondido.Pos_Situacao_Resp eq 14 and rs14SN.recordcount lte 0>
						<cfquery datasource="#dsn_inspecao#">
							INSERT Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Area)
							VALUES ('#qNaoRespondido.Pos_Inspecao#', '#qNaoRespondido.Pos_Unidade#', #qNaoRespondido.Pos_NumGrupo#, #Pos_NumItem#, convert(char, getdate(), 102), '#CGI.REMOTE_USER#', 14, left(convert(char, getdate(), 114),10),'#FORM.unid#')
						</cfquery>
					</cfif>

				</cfoutput>
			<!--- fim Verificaçaõ dos registros que estão na situação 14(Não Respondido) na tabela ParecerUnidade --->
				
		<!---Fim do prcesso de liberação da avaliação--->
		

		<script>
			<cfoutput>
				var	pg = '#URL.pg#';
				
			</cfoutput>
			if( pg == 'pt'){
				window.opener.location.reload();
			}
			<cfoutput>	
				<cfif qInspecaoLiberada.recordCount neq 0 or qVerifEmReanalise.recordCount neq 0>
					alert("Reanálise cancelada!");
				</cfif>
			</cfoutput>
			window.close(); 
		</script>
</cfif>

<cfif isDefined("Form.acao") and "#form.acao#" eq 'validar'>
            <cfquery datasource="#dsn_inspecao#" name="rsVerificaItem">
				SELECT  RIP_Resposta, RIP_Unidade, RIP_NCISEI, RIP_Falta, RIP_Sobra, RIP_REINCINSPECAO FROM Resultado_Inspecao 
				WHERE RIP_NumInspecao='#FORM.Ninsp#' And RIP_NumGrupo = '#FORM.Ngrup#' and RIP_NumItem ='#FORM.Nitem#' 
			</cfquery>
			<cfparam name="FORM.unid" default="#rsVerificaItem.RIP_Unidade#">
  			<!--- Update na tabela Resultado_Inspecao--->
			<cfquery datasource="#dsn_inspecao#">
				UPDATE Resultado_Inspecao set RIP_Recomendacao = 'V'
				WHERE RIP_NumInspecao = '#URL.Ninsp#' and RIP_NumGrupo ='#url.Ngrup#' and RIP_NumItem ='#url.Nitem#'
			</cfquery>

			<!---Veirifica se esta inspeção possui algum item em reanálise --->
			<cfquery datasource="#dsn_inspecao#" name="qVerifEmReanalise">
				SELECT RIP_Resposta, RIP_Recomendacao FROM Resultado_Inspecao 
				WHERE (RIP_Recomendacao='S' OR RIP_Recomendacao='R') and RIP_NumInspecao='#ninsp#'  
			</cfquery>
			<cfif qVerifEmReanalise.recordCount eq 0>
			    <cfquery datasource="#dsn_inspecao#">
					UPDATE Inspecao SET INP_Situacao ='CO' WHERE INP_NumInspecao ='#ninsp#'
				</cfquery>
			</cfif> 
          

			<!---Início do processo de liberação da avaliação--->
			    <!---Veirifica se esta inspeção possui algum item Em Revisão --->	
				<cfquery name="qInspecaoLiberada" datasource="#dsn_inspecao#">
					SELECT * FROM ParecerUnidade 
					WHERE Pos_Inspecao='#ninsp#' AND Pos_Situacao_Resp = 0
				</cfquery>
				
				<!---Verifica se esta inspeção possui algum item não avaliado (todos os NÃO VERIFICADO e os NÂO EXECUTA em que o campo Itn_ValidacaoObrigatoria for igual a 1) --->
				<cfquery datasource="#dsn_inspecao#" name="qVerifValidados">
					SELECT RIP_Resposta, RIP_Recomendacao 
					FROM Resultado_Inspecao 
					INNER JOIN Inspecao ON RIP_NumInspecao = INP_NumInspecao AND RIP_Unidade = INP_Unidade
					INNER JOIN Unidades ON	Und_Codigo = RIP_Unidade
					INNER JOIN Itens_Verificacao ON Itn_Ano = convert(char(4),RIP_Ano) AND INP_Modalidade = Itn_Modalidade and Itn_NumGrupo = RIP_NumGrupo AND Itn_NumItem = RIP_NumItem and Itn_TipoUnidade = Und_TipoUnidade
					WHERE ((RTRIM(RIP_Resposta)= 'E' AND Itn_ValidacaoObrigatoria=1) OR RTRIM(RIP_Resposta)= 'V') AND RTRIM(RIP_Recomendacao) IS NULL AND RIP_NumInspecao='#ninsp#' and RIP_Unidade='#unid#' AND (Itn_TipoUnidade = #url.tpunid#)
				</cfquery>


				<!---Início - Se não existirem itens em revisão e não existirem itens em reavaliação e nao existirem itens a serem validados,
				     inicia o processo de liberação de todos os itens--->	
					<cfif qInspecaoLiberada.recordCount eq 0 and qVerifEmReanalise.recordCount eq 0 and qVerifValidados.recordCount eq 0>
						<!---Salva a matricula do gestor na tabela Inspecao para sinalisar o gestor que liberou a verificação --->
						<cfquery datasource="#dsn_inspecao#">
							UPDATE Inspecao SET INP_Situacao ='CO', INP_UserName = '#qAcesso.Usu_Matricula#', INP_DTUltAtu = CONVERT(char, getdate(), 120)
							WHERE INP_NumInspecao ='#ninsp#'
						</cfquery>

						<cfquery name="rs11" datasource="#dsn_inspecao#">
							SELECT Und_TipoUnidade, Und_Centraliza, Itn_TipoUnidade, Itn_PTC_Seq, Itn_Pontuacao, Itn_Classificacao, Pos_Unidade, Pos_NumGrupo, Pos_NumItem, Pos_Area, Pos_NomeArea, Pos_Situacao_Resp
							FROM Itens_Verificacao 
							INNER JOIN (ParecerUnidade 
							INNER JOIN Inspecao ON 
							 Pos_Inspecao = INP_NumInspecao AND Pos_Unidade = INP_Unidade
							INNER JOIN Unidades ON Pos_Unidade = Und_Codigo) ON (Itn_Ano = '#right(ninsp)#' and INP_Modalidade = Itn_Modalidade and Itn_TipoUnidade = Und_TipoUnidade and Itn_NumItem = Pos_NumItem AND Itn_NumGrupo = Pos_NumGrupo) 
							WHERE Pos_Inspecao='#ninsp#' AND Pos_Situacao_Resp = 11 and (Itn_TipoUnidade = #url.tpunid#)
						</cfquery> 
						
					<!--- inicio 10 (dez) dias uteis para status 14-NR --->
					<cfif rs11.recordcount gt 0>
						<cfset auxdtprev = CreateDate(year(now()),month(now()),day(now()))>
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
					</cfif>
					<!--- fim 10 (dez) dias uteis para status 14-NR --->	
										
						<!---Início -Se existirem itens em liberação, executa a rotina para mudança do status de todos os itens
							em liberação para não respondido--->
							<cfloop query="rs11">
								<cfset auxposarea = rs11.Pos_Area>
								<cfset auxnomearea = rs11.Pos_NomeArea>
								
								<cfif (rs11.Und_Centraliza neq "") and (rs11.Itn_TipoUnidade eq 4)>
										<cfquery name="rsCDD" datasource="#dsn_inspecao#">
										SELECT Und_Descricao FROM Unidades WHERE Und_Codigo = '#rs11.Und_Centraliza#'
										</cfquery>
										<cfset auxposarea = rs11.Und_Centraliza>
										<cfset auxnomearea = rsCDD.Und_Descricao>
								</cfif>
					<!--- inicio classificacao do ponto --->
								<cfset composic = rs11.Itn_PTC_Seq>	
								<cfset ItnPontuacao = rs11.Itn_Pontuacao>
								<cfset ClasItem_Ponto = ucase(trim(rs11.Itn_Classificacao))>
								 <cfset somafaltasobra=0>
										
								<cfset impactosn = 'N'>
								<cfif left(composic,2) eq '10'>
									<cfset impactosn = 'S'>
								</cfif>
								<cfset fator = 1>
							
								<cfif impactosn eq 'S'>
									<cfquery name="rsRelev" datasource="#dsn_inspecao#">
										SELECT VLR_Fator, VLR_FaixaInicial, VLR_FaixaFinal
										FROM ValorRelevancia
										WHERE VLR_Ano = right('#Ninsp#',4))
									</cfquery
									 <cfset somafaltasobra = rsVerificaItem.RIP_Falta>
									 <cfif (rs11.Pos_NumItem eq 1 and (rs11.Pos_NumGrupo eq 53 or rs11.Pos_NumGrupo eq 72 or rs11.Pos_NumGrupo eq 214 or rs11.Pos_NumGrupo eq 284))>
										<cfset somafaltasobra = somafaltasobra + rsVerificaItem.RIP_Sobra>
									 </cfif>
									 <cfif somafaltasobra gt 0>
										<cfloop query="rsRelev">
											 <cfif rsRelev.VLR_FaixaInicial is 0 and rsRelev.VLR_FaixaFinal lte somafaltasobra>
												<cfset fator = rsRelev.VLR_Fator>
											 <cfelseif rsRelev.VLR_FaixaInicial neq 0 and VLR_FaixaFinal neq 0 and somafaltasobra gt rsRelev.VLR_FaixaInicial and somafaltasobra lte rsRelev.VLR_FaixaFinal>
												<cfset fator = rsRelev.VLR_Fator>									
											 <cfelseif VLR_FaixaFinal eq 0 and somafaltasobra gt rsRelev.VLR_FaixaInicial>
												<cfset fator = rsRelev.VLR_Fator> 								
											 </cfif>
										</cfloop>
									</cfif>	
								</cfif>	
								<cfset ItnPontuacao =  (ItnPontuacao * fator)>	
								<cfif impactosn eq 'S'>
										<!--- Ajustes para os campos: Pos_ClassificacaoPonto --->
										<!--- Obter a pontuacao max pelo ano e tipo da unidade --->
										<cfquery name="rsPtoMax" datasource="#dsn_inspecao#">
											SELECT TUP_PontuacaoMaxima 
											FROM Tipo_Unidade_Pontuacao 
											WHERE TUP_Ano = '#right(url.numInspecao,4)#' AND TUP_Tun_Codigo = #rsItem2.Itn_TipoUnidade#
										</cfquery> 
										<!--- calcular o perc de classificacao do item --->	
										<cfset PercClassifPonto = NumberFormat(((ItnPontuacao / rsPtoMax.TUP_PontuacaoMaxima) * 100),999.00)>	
										
										<!--- calculo da descricao do item a saber GRAVE, MEDIANO ou LEVE --->
										
										<cfif PercClassifPonto gt 50.01>
										<cfset ClasItem_Ponto = 'GRAVE'> 
										<cfelseif PercClassifPonto gt 10 and PercClassifPonto lte 50.01>
										<cfset ClasItem_Ponto = 'MEDIANO'> 
										<cfelseif PercClassifPonto lte 10>
										<cfset ClasItem_Ponto = 'LEVE'> 
										</cfif>	
								</cfif>	
								<cfif ClasItem_Ponto eq 'LEVE'	and len(trim(rsVerificaItem.RIP_REINCINSPECAO)) gt 0>
									  <cfset ClasItem_Ponto = 'MEDIANO'>
								</cfif>				
						<!--- fim classificacao do ponto --->								
								<!---Update na tabela parecer unidade--->
								<cfquery datasource="#dsn_inspecao#">
									UPDATE ParecerUnidade SET Pos_Area = '#auxposarea#'
									, Pos_NomeArea = '#auxnomearea#'
									, Pos_Situacao_Resp = 14
									, Pos_Situacao = 'NR'
									, Pos_DtPosic = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#
									, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(auxdtprev),month(auxdtprev),day(auxdtprev)))#
									, Pos_DtUltAtu = CONVERT(char, GETDATE(), 120) 
									, pos_username = '#CGI.REMOTE_USER#' 
									, Pos_Sit_Resp_Antes = #rs11.Pos_Situacao_Resp#
									WHERE Pos_Inspecao='#ninsp#' and Pos_NumGrupo = #rs11.Pos_NumGrupo# and Pos_NumItem = #rs11.Pos_NumItem# and Pos_Situacao_Resp = 11
								</cfquery>
								
							</cfloop>
						<!---Fim -Se existirem itens em liberação, executa a rotina para mudança do status de todos os itens
							em liberação para não respondido--->

						<!--- Início - e-mail automático por unidade --->
							<cfquery name="rsEmail" datasource="#dsn_inspecao#">
								SELECT Pos_Area, Pos_NomeArea, Pos_Unidade, Und_TipoUnidade, Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Und_CodReop, INP_DtInicInspecao
								FROM Inspecao INNER JOIN (Unidades INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade) ON (INP_NumInspecao = Pos_Inspecao) AND (INP_Unidade = Pos_Unidade)
								WHERE (Pos_Unidade = '#FORM.unid#') AND (Pos_Inspecao = '#ninsp#') AND (Pos_Situacao_Resp = 14)
							</cfquery>

							<cfoutput>
								<cfset emailunid = "">
								<cfset emailreopunid = "">
								<cfset emailcdd = "">
								<cfset emailreopcdd = "">

								<cfif rsEmail.recordcount gt 0>
									<!--- Busca de email da Unidade --->
									<cfloop query="rsEmail">
										<cfif rsEmail.Pos_Area eq rsEmail.Pos_Unidade and emailunid eq "">
										<!--- adquirir o email dos registro do Pos_Area --->
											<cfquery name="rsPosUnidEmail" datasource="#dsn_inspecao#">
											SELECT Und_Descricao, Und_Email FROM Unidades WHERE Und_Codigo = '#rsEmail.Pos_Unidade#'
											</cfquery>
											<cfset emailunid = #rsPosUnidEmail.Und_Email#>
											<!--- adquirir o email do OrgaoSubordiador --->
											<cfquery name="rsReopunidEmail" datasource="#dsn_inspecao#">
											SELECT Rep_Email FROM Reops WHERE Rep_Codigo = '#rsEmail.Pos_Unidade#'
											</cfquery>
											<cfset emailreopunid = #rsReopunidEmail.Rep_Email# >
										</cfif>
										<!--- Busca de email do CDD --->
										<cfif rsEmail.Pos_Area neq rsEmail.Pos_Unidade and emailcdd eq "">
										<!--- adquirir o email dos registro do Pos_Area --->
											<cfquery name="rsPosAreaEmail" datasource="#dsn_inspecao#">
											SELECT Und_Descricao, Und_Email FROM Unidades WHERE Und_Codigo = '#rsEmail.Pos_Area#'
											</cfquery>
											<cfset emailcdd = #rsPosAreaEmail.Und_Email#>

											<!--- adquirir o email do OrgaoSubordiador --->
											<cfquery name="rsReopcddEmail" datasource="#dsn_inspecao#">
											SELECT Rep_Email FROM Reops WHERE Rep_Codigo = '#rsEmail.Pos_Area#'
											</cfquery>
											<cfset emailreopcdd = #rsReopcddEmail.Rep_Email# >
										</cfif>
									</cfloop>

									<cfset sdestina = "">
									<cfif emailunid neq "">
									<cfset sdestina = #sdestina# & ';' & #emailunid#>
									</cfif>

									<cfif emailreopunid neq "">
									<cfset sdestina = #sdestina# & ';' & #emailreopunid#>
									</cfif>

									<cfif emailcdd neq "">
									<cfset sdestina = #sdestina# & ';' & #emailcdd#>
									</cfif>

									<cfif emailreopcdd neq "">
									<cfset sdestina = #sdestina# & ';' & #emailreopcdd#>
									</cfif>

									<cfif findoneof("@", trim(sdestina)) eq 0>
										<cfset sdestina = "gilvanm@correios.com.br">
									</cfif>

							
									<!--- adquirir o email do SCOI da SE --->
									<cfquery name="rsSCOIEmail" datasource="#dsn_inspecao#">
										SELECT Ars_Email
										FROM Areas
										WHERE (Ars_Codigo Like 'left(#ninsp#,2)%') AND 
										(Ars_Sigla Like '%CCOP/SCOI%' OR Ars_Sigla Like '%DCINT/GCOP/SGCIN/SCOI') AND (Ars_Status='A')
									</cfquery>

									<cfset assunto = 'Relatório de Controle Interno - ' & #trim(rsEmail.Und_Descricao)# & ' - Avaliação de Controle Interno ' & #ninsp#>
									<cfmail from="SNCI@correios.com.br" to="#sdestina#" subject="#assunto#" type="HTML">
										Mensagem autom?tica. Não precisa responder!<br><br>
										<strong>
										Prezado(a) Gerente do(a) #trim(Ucase(rsEmail.Und_Descricao))#, informamos que estão disponível na intranet o Relatório de Controle Interno: N° #ninsp#, realizada nessa Unidade na Data: #dateformat(rsEmail.INP_DtInicInspecao,"dd/mm/yyyy")#. <br><br><br>

									&nbsp;&nbsp;&nbsp;Solicitamos acessá-lo para registro de sua resposta, conforme orientações a seguir:<br><br>

									&nbsp;&nbsp;&nbsp;a) Informar a Justificativa para ocorrência da falha: o que ocasionou o Problema (CAUSA); <br>

									&nbsp;&nbsp;&nbsp;b) Informar o Plano de Ações adotado para regularização da falha detectada, com prazo de implementação;<br>

									&nbsp;&nbsp;&nbsp;c) Anexar no sistema os Comprovantes de regularização da situação encontrada e/ou das Ações implementadas (em PDF).<br><br>

									&nbsp;&nbsp;&nbsp;Registrar a resposta no Sistema Nacional de Controle Interno - SNCI  num prazo de dez (10) dias úteis, contados a partir da data de entrega do Relatório. <br>
									&nbsp;&nbsp;&nbsp;O Não cumprimento desse prazo ensejará comunicação ao órgão subordinador dessa unidade.<br><br>

									&nbsp;&nbsp;&nbsp;Acesse o SNCI clicando no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">Relatório de Controle Interno.</a><br><br>

									&nbsp;&nbsp;&nbsp;Atentar para as orientações deste e-mail para registro de sua manifestação no SNCI. Respostas incompletas serão devolvidas para complementação. <br><br>

									&nbsp;&nbsp;&nbsp;Em caso de dúvidas, entrar em contato com a Equipe de Controle Interno localizada na SE, por meio do endereço eletrônico:  #rsSCOIEmail.Ars_Email#.<br><br>

									<table>
									<tr>
									<td><strong>Unidade : #rsEmail.Pos_Unidade# - #rsEmail.Und_Descricao#</strong></td>
									</tr>
									<tr>
									<td><strong>Inspeção: #rsEmail.Pos_Inspecao#</strong></td>
									</tr>
									<tr>
									<td><strong>------------------------------------------</strong></td>
									</tr>
									</table>
									<br>
									&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
									</strong>
									</cfmail>
								</cfif>
							</cfoutput>
						<!--- Fim - e-mail automático por unidade --->
					</cfif>
				<!---Fim do processo de liberação de todos os itens--->	
				<!--- Início Verificação dos registros que estão na situação 14(Não Respondido) na tabela ParecerUnidade --->
					<cfquery name="qNaoRespondido" datasource="#dsn_inspecao#">
						SELECT Pos_Inspecao, Pos_Unidade, Pos_NumGrupo, Pos_NumItem, Pos_Situacao_Resp FROM ParecerUnidade
						WHERE Pos_Inspecao='#ninsp#' AND Pos_Situacao_Resp = 14
					</cfquery>
					
					<cfoutput query="qNaoRespondido">
						<cfquery name="rs14SN" datasource="#dsn_inspecao#">
							SELECT And_NumInspecao FROM Andamento
							WHERE And_Unidade='#qNaoRespondido.Pos_Unidade#' AND And_NumInspecao='#qNaoRespondido.Pos_Inspecao#' AND And_NumGrupo=#qNaoRespondido.Pos_NumGrupo# AND And_NumItem=#qNaoRespondido.Pos_NumItem# 
							AND And_Situacao_Resp = 14
						</cfquery> 
						
						<cfif qNaoRespondido.Pos_Situacao_Resp eq 14 and rs14SN.recordcount lte 0>
							<cfquery datasource="#dsn_inspecao#">
								INSERT Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Area)
								VALUES ('#qNaoRespondido.Pos_Inspecao#', '#qNaoRespondido.Pos_Unidade#', #qNaoRespondido.Pos_NumGrupo#, #qNaoRespondido.Pos_NumItem#, convert(char, getdate(), 102), '#CGI.REMOTE_USER#', 14, left(convert(char, getdate(), 114),10),'#FORM.unid#')
							</cfquery>
						</cfif>

					</cfoutput>
				<!--- fim Verificaçaõ dos registros que estão na situação 14(Não Respondido) na tabela ParecerUnidade --->
					
			<!---Fim do prcesso de liberação da avaliação--->

			<script>
				<cfoutput>
					var	pg = '#URL.pg#';
					
				</cfoutput>
				 if( pg == 'pt'){
					window.opener.location.reload();
				}
				<cfoutput>	
					<cfif qInspecaoLiberada.recordCount neq 0 or qVerifEmReanalise.recordCount neq 0>
						alert("Reanálise validada!");
					</cfif>
				</cfoutput>
				
			    window.close(); 
			</script>
</cfif>


<cfif isDefined("Form.acao") and "#form.acao#" eq 'resp'>

	<cfif "#form.recomendacao#" neq ''>
	
		<cftransaction>
			<!--- Update na tabela Resultado_Inspecao--->
			<cfquery datasource="#dsn_inspecao#">
				UPDATE Resultado_Inspecao set 
				<cfif ('#qAcesso.Usu_GrupoAcesso#' eq 'gestores' or '#qAcesso.Usu_GrupoAcesso#' eq 'desenvolvedores') >
					RIP_Recomendacao = 'S', RIP_Recomendacao_Inspetor = '#form.recomendacao#'
				<cfelse>
					RIP_Critica_Inspetor='#form.respInsp#'
				</cfif>
				WHERE RIP_NumInspecao = '#URL.Ninsp#' and RIP_NumGrupo ='#url.Ngrup#' and RIP_NumItem ='#url.Nitem#'
			</cfquery>
			<cfif ('#qAcesso.Usu_GrupoAcesso#' eq 'gestores' or '#qAcesso.Usu_GrupoAcesso#' eq 'desenvolvedores')>
				<!--- Update na tabela Inspecao com sigla  NA = não avaliada, ER = em reavaliação, RA = reavaliada, CO = concluída--->
				<cfquery datasource="#dsn_inspecao#">
					UPDATE Inspecao set INP_Situacao ='ER'
					WHERE INP_NumInspecao = '#URL.Ninsp#' 
				</cfquery>
				<!--- Deleta o item da tabela ParecerUnidade--->
				<cfquery datasource="#dsn_inspecao#">
					DELETE FROM ParecerUnidade
					WHERE Pos_Inspecao = '#URL.Ninsp#' and Pos_NumGrupo ='#url.Ngrup#' and Pos_NumItem ='#url.Nitem#' 
				</cfquery>
				<!--- Deleta o item da tabela Andamento--->
				<cfquery datasource="#dsn_inspecao#">
					DELETE FROM Andamento
					WHERE And_NumInspecao = '#URL.Ninsp#' and And_NumGrupo ='#url.Ngrup#' and And_NumItem ='#url.Nitem#' 
				</cfquery>

				<cfquery name="rsEmail" datasource="#dsn_inspecao#">
					SELECT RIP_NumGrupo, RIP_NumItem, RIP_NumInspecao, RIP_MatricAvaliador, Usu_Matricula, Usu_Apelido, Und_Codigo, LTRIM(RTRIM(Und_Descricao)) as Und_Descricao, LTRIM(RTRIM(Usu_Email)) as Usu_Email ,
					       CASE WHEN LTRIM(RTRIM(RIP_MatricAvaliador))=LTRIM(RTRIM(Usu_Matricula)) THEN 1 ELSE 0 END AS Avaliador 
					FROM Resultado_Inspecao
					INNER JOIN Inspetor_Inspecao ON IPT_NumInspecao = RIP_NumInspecao
					INNER JOIN Usuarios ON Usu_Matricula = IPT_MatricInspetor
					INNER JOIN Unidades ON Und_Codigo = RIP_Unidade
					WHERE  RIP_NumInspecao = '#URL.Ninsp#' AND RIP_NumGrupo ='#url.Ngrup#' AND RIP_NumItem ='#url.Nitem#'
				</cfquery>	
				<cfquery name="rsAvaliador" dbType="query">
					SELECT Usu_Matricula, Usu_Apelido FROM rsEmail WHERE Avaliador = 1
				</cfquery>

				<cfset Num_Insp = Left(rsEmail.RIP_NumInspecao,2) & '.' & Mid(rsEmail.RIP_NumInspecao,3,4) & '/' & Right(rsEmail.RIP_NumInspecao,4)>
                <cfset Num_Matricula =Left(rsAvaliador.Usu_Matricula,'1')& '.' & Mid(rsAvaliador.Usu_Matricula,2,3)& '.' & Mid(rsAvaliador.Usu_Matricula,5,3)& '-' & Right(rsAvaliador.Usu_Matricula,1)>

				<cfset auxsite =  cgi.server_name>
				<cfif auxsite eq "intranetsistemaspe">
					<cfset sdestina =''>
				    <cfoutput query="rsEmail">
						<cfset sdestina = Usu_Email & ';' & sdestina>
					</cfoutput>						
				<cfelse>
					<cfset sdestinaTeste =''>
					<cfoutput query="rsEmail">
						<cfset sdestinaTeste = Usu_Email & ';' & sdestinaTeste>
					</cfoutput>	
                    <cfset sdestina = '#qAcesso.Usu_Email#'>
				</cfif>
				<cfset myImgPath = expandPath('./')>
				<cfset assunto = 'SNCI - AVALIAÇÃO N° ' & '#Num_Insp#' & ' - ' & '#trim(rsEmail.Und_Descricao)#' >
				<cfset auxdr = left(URL.Ninsp,2)>
				<cfif auxdr eq '32' or auxdr eq '04' or auxdr eq '30' or auxdr eq '70' or auxdr eq '60' or auxdr eq '34' or auxdr eq '18' or auxdr eq '12'>
					<cfset sdestina = sdestina & ';' & 'EDIMIR@correios.com.br'>
				</cfif>
				<cfmail from="SNCI@correios.com.br" to="#sdestina#" subject="#assunto#" type="HTML">
				<cfoutput>
					<div>
						<p><strong>Atenção! E-mail automático, não responda.</strong></p>
						<p>Prezados inspetores,</p>
						<p>Informa-se que existem itens no SNCI pendentes de REANÁLISE. Favor acessar a opção "Avaliação e Reanálise de Itens" na tela inicial do sistema e realizar os ajustes solicitados pelo revisor.</p> 
						<p>Avaliação: <span style="color:blue"><strong>#trim(Num_Insp)#</strong></span></p>
						<p>Item: <span style="color:blue"><strong>#rsEmail.RIP_NumGrupo#.#rsEmail.RIP_NumItem#</strong></span></p>
						<p>Unidade: <span style="color:blue"><strong>#trim(rsEmail.Und_Descricao)#</strong></span></p>
						<p>Item avaliado por: <span style="color:blue"><strong>#Num_Matricula# - #trim(rsAvaliador.Usu_Apelido)#</strong></span></p>
						<!--- Mostrado apenas em homologação e desenvolvimento --->	
						<cfif auxsite neq "intranetsistemaspe">
							<p><span style="color:red">Em Produção este e-mail seria encaminhado para:</span> #sdestinaTeste#</p>
						</cfif>
						<cfmailparam disposition="inline" contentid="topoginsp" file="#myImgPath#topoginsp.jpg">
						<p><a href="http://intranetsistemaspe/SNCI/"><img src="cid:topoginsp.jpg" width="50%" align=middle ></a></p>
						
					</div>
				</cfoutput>
					
				</cfmail>


			</cfif>
		</cftransaction>
		<script>	
				
                <cfoutput>
					var	pg = '#url.pg#';
				</cfoutput>
				if( pg == 'pt'){
					window.opener.location.reload();
				}	
				<cfif ('#qAcesso.Usu_GrupoAcesso#' eq 'gestores' or '#qAcesso.Usu_GrupoAcesso#' eq 'desenvolvedores')>
					alert("Item enviado para Reanálise do Inspetor.\n\nObs.: Foi encaminhado um e-mail de aviso para a caixa postal do inspetor.");
				<cfelse>
					alert("Resposta salva!");
				</cfif>
				
			 	window.close(); 
		</script>

	</cfif>
</cfif>


<cfif isDefined("Form.acao") and "#form.acao#" eq 'respSemAlteracao'>	
			
		<!--- Update na tabela Resultado_Inspecao--->
		<cfquery datasource="#dsn_inspecao#">
			UPDATE Resultado_Inspecao set 
				RIP_Recomendacao = 'R', RIP_Critica_Inspetor='#form.respInsp#'
			WHERE RIP_NumInspecao = '#URL.Ninsp#' and RIP_NumGrupo ='#url.Ngrup#' and RIP_NumItem ='#url.Nitem#'
		</cfquery>
			
		<cfquery datasource="#dsn_inspecao#" name="rsVerificaItem">
			SELECT  RIP_Resposta, RIP_Unidade, RIP_NCISEI, RIP_Falta, RIP_Sobra, RIP_REINCINSPECAO FROM Resultado_Inspecao 
			WHERE RIP_NumInspecao='#FORM.Ninsp#' And RIP_NumGrupo = '#FORM.Ngrup#' and RIP_NumItem ='#FORM.Nitem#' 
		</cfquery>
		<cfparam name="FORM.unid" default="#rsVerificaItem.RIP_Unidade#">
		
						<!--- 	Verifica se ainda existem itens em reanálise.	 --->
						<cfquery datasource="#dsn_inspecao#" name="rsVerifItensEmReanalise">
								SELECT RIP_Resposta, RIP_Recomendacao, INP_Modalidade
								FROM Resultado_Inspecao 
								INNER JOIN Inspecao ON 
								RIP_NumInspecao = INP_NumInspecao AND RIP_Unidade = INP_Unidade
								WHERE  RIP_Recomendacao='S' and RIP_NumInspecao='#FORM.Ninsp#'     
						</cfquery>
		
			            <!--- Dado default para registro no campo Pos_Area --->
						<cfset posarea_cod = '#FORM.unid#'>	
						<!--- Obter o tipo da Unidade e sua descrição para alimentar o Pos_AreaNome --->
						
						<cfquery name="rsUnid" datasource="#dsn_inspecao#">
							SELECT Und_Centraliza, Und_Descricao, Und_TipoUnidade 
							FROM Unidades 
							WHERE Und_Codigo = '#FORM.unid#'
						</cfquery>
						<!--- Dado default para registro no campo Pos_AreaNome --->
						<cfset posarea_nome = rsUnid.Und_Descricao>
						<!--- Buscar o tipo de TipoUnidade que pertence a resposta do item --->

						<cfquery name="rsItem2" datasource="#dsn_inspecao#">
							SELECT Itn_TipoUnidade, Itn_Pontuacao, Itn_Classificacao, Itn_PTC_Seq
							FROM Itens_Verificacao 
							WHERE (Itn_Ano = right('#FORM.Ninsp#',4)) and 
							(Itn_Modalidade = '#rsVerifItensEmReanalise.INP_Modalidade#')
							(Itn_NumGrupo = '#FORM.Ngrup#') AND 
							(Itn_NumItem = '#FORM.Nitem#') and 
							(Itn_TipoUnidade = #url.tpunid#)
						</cfquery>
						<!--- Verificara possibilidade de alterar os dados default para Pos_Area e Pos_AreaNome ---> 
						<cfif (trim(rsUnid.Und_Centraliza) neq "") and (rsItem2.Itn_TipoUnidade eq 4)>
							<!--- AC é Centralizada por CDD? --->
							<cfquery name="rsCDD" datasource="#dsn_inspecao#">
								SELECT Und_Descricao FROM Unidades WHERE Und_Codigo = '#rsUnid.Und_Centraliza#'
							</cfquery>
							<cfset posarea_cod = #rsUnid.Und_Centraliza#>
							<cfset posarea_nome = #rsCDD.Und_Descricao#>
						</cfif>
						<!--- Se a valição for não conforme, iniciar um insert na tabela parecer unidade --->
						<cfif '#rsVerificaItem.RIP_Resposta#' eq 'N'>
<!--- inicio classificacao do ponto --->
					<cfset composic = rsItem2.Itn_PTC_Seq>	
					<cfset ItnPontuacao = rsItem2.Itn_Pontuacao>
					<cfset ClasItem_Ponto = ucase(trim(rsitem2.Itn_Classificacao))>
										
					<cfset impactosn = 'N'>
					<cfif left(composic,2) eq '10'>
						<cfset impactosn = 'S'>
					</cfif>
					<cfset fator = 1>
					<cfif impactosn eq 'S'>
						<cfquery name="rsRelev" datasource="#dsn_inspecao#">
							SELECT VLR_Fator, VLR_FaixaInicial, VLR_FaixaFinal
							FROM ValorRelevancia
							WHERE VLR_Ano = right('#FORM.Ninsp#',4))
						</cfquery>
						 <cfset somafaltasobra = rsVerificaItem.RIP_Falta>
						 <cfif (FORM.Nitem eq 1 and (FORM.Ngrup eq 53 or FORM.Ngrup eq 72 or FORM.Ngrup eq 214 or FORM.Ngrup eq 284))>
							<cfset somafaltasobra = somafaltasobra + rsVerificaItem.RIP_Sobra>
						 </cfif>
						 <cfif somafaltasobra gt 0>
							<cfloop query="rsRelev">
								 <cfif rsRelev.VLR_FaixaInicial is 0 and rsRelev.VLR_FaixaFinal lte somafaltasobra>
									<cfset fator = rsRelev.VLR_Fator>
								 <cfelseif rsRelev.VLR_FaixaInicial neq 0 and VLR_FaixaFinal neq 0 and somafaltasobra gt rsRelev.VLR_FaixaInicial and somafaltasobra lte rsRelev.VLR_FaixaFinal>
									<cfset fator = rsRelev.VLR_Fator>
								 <cfelseif VLR_FaixaFinal eq 0 and somafaltasobra gt rsRelev.VLR_FaixaInicial>
									<cfset fator = rsRelev.VLR_Fator> 
								 </cfif>
							</cfloop>
						</cfif>	
					</cfif>	
					<cfset ItnPontuacao =  (ItnPontuacao * fator)>
	                <cfif impactosn eq 'S'>
							<!--- Ajustes para os campos: Pos_ClassificacaoPonto --->
							<!--- Obter a pontuacao max pelo ano e tipo da unidade --->
							<cfquery name="rsPtoMax" datasource="#dsn_inspecao#">
								SELECT TUP_PontuacaoMaxima 
								FROM Tipo_Unidade_Pontuacao 
								WHERE TUP_Ano = '#right(FORM.Ninsp,4)#' AND TUP_Tun_Codigo = #rsItem2.Itn_TipoUnidade#
							</cfquery>
							<!--- calcular o perc de classificacao do item --->	
							<cfset PercClassifPonto = NumberFormat(((ItnPontuacao / rsPtoMax.TUP_PontuacaoMaxima) * 100),999.00)>	
							
							<!--- calculo da descricao do item a saber GRAVE, MEDIANO ou LEVE --->
							
							<cfif PercClassifPonto gt 50.01>
							<cfset ClasItem_Ponto = 'GRAVE'> 
							<cfelseif PercClassifPonto gt 10 and PercClassifPonto lte 50.01>
							<cfset ClasItem_Ponto = 'MEDIANO'> 
							<cfelseif PercClassifPonto lte 10>
							<cfset ClasItem_Ponto = 'LEVE'> 
							</cfif>	
						</cfif>	 	
						<cfif ClasItem_Ponto eq 'LEVE'	and len(trim(rsVerificaItem.RIP_REINCINSPECAO)) gt 0>
							  <cfset ClasItem_Ponto = 'MEDIANO'>
						</cfif>				
	<!--- fim classificacao do ponto --->					
							<cfquery datasource="#dsn_inspecao#">
								INSERT INTO ParecerUnidade (Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_NomeResp, Pos_Situacao, Pos_Parecer, Pos_co_ci, Pos_dtultatu, Pos_username, Pos_aval_dinsp, Pos_Situacao_Resp, Pos_Area, Pos_NomeArea, Pos_NCISEI, Pos_PontuacaoPonto, Pos_ClassificacaoPonto) 
								VALUES ('#FORM.unid#', '#FORM.Ninsp#', #FORM.Ngrup#, #FORM.Nitem#, 
										CONVERT(char, GETDATE(), 102), '#CGI.REMOTE_USER#', 'RE', '', 'INTRANET', CONVERT(char, GETDATE(), 120), '#CGI.REMOTE_USER#', NULL, 0,
										'#posarea_cod#','#posarea_nome#','#rsVerificaItem.RIP_NCISEI#', #ItnPontuacao#,'#ClasItem_Ponto#')
							</cfquery>
							<!---Fim Insere ParecerUnidade --->
						
							<!--- Inserindo dados dados na tabela Andamento --->
							<cfset andparecer = #posarea_cod#  & " --- " & #posarea_nome#>
							<cfquery datasource="#dsn_inspecao#">
								insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, and_Parecer, And_Area) 
								values ('#FORM.Ninsp#', '#FORM.unid#', #FORM.Ngrup#, #FORM.Nitem#, convert(char, getdate(), 102), '#CGI.REMOTE_USER#', 0, CONVERT(char, GETDATE(), 108), '#andparecer#', '#posarea_cod#')
							</cfquery>
							<!---Fim Insere Andamento --->
						</cfif> 
						<!---  Se o tem era uma reanálise e não existirem mais itens em reanálise, a finalização da verificação é realizada nesta página
						e não em itens_inspetores_avaliacao.cfm como acontece para as outras avaliações--->
						<cfif rsVerifItensEmReanalise.recordCount eq 0>
								<!---UPDATE em Inspecao--->
								<cfquery datasource="#dsn_inspecao#" ><!---Inspeções NA = não avaliadas, ER = em reavaliação, RA =reavaliado, CO = concluída---> 
									UPDATE Inspecao SET INP_Situacao = 'RA', INP_DtEncerramento =  CONVERT(char, GETDATE(), 102), INP_DtUltAtu =  CONVERT(char, GETDATE(), 120), INP_UserName ='#qAcesso.Usu_Matricula#'
									WHERE INP_Unidade='#FORM.unid#' AND INP_NumInspecao='#FORM.Ninsp#' 
								</cfquery>
								<!---Fim UPDATE em Inspecao
								<cflocation url = "itens_inspetores_avaliacao.cfm" addToken = "no"> --->
								<script>
									<cfoutput>
										window.opener.location.href="itens_inspetores_avaliacao.cfm";
									</cfoutput>
								</script>
						<cfelse>
								<script>
									<cfoutput>
										window.opener.location.href="itens_inspetores_avaliacao.cfm?numInspecao=#form.Ninsp#&Unid=#form.unid#";
									</cfoutput>
								</script>
						</cfif>		
		 				
		<script>
			window.close();
		</script>
</cfif>


<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title><cfif ('#qAcesso.Usu_GrupoAcesso#' eq 'gestores' or '#qAcesso.Usu_GrupoAcesso#' eq 'desenvolvedores')>SNCI - ENVIA O ITEM PARA REANÁLISE PELO INSPETOR<CFELSE>SNCI - RECOMENDAÇÕES AO INSPETOR</CFIF></title>
<link rel="stylesheet" type="text/css" href="view.css" media="all">


<script type="text/javascript">
    function atualizaPT() {
		<cfoutput>
			var	pg = '#url.pg#';
		</cfoutput>
                if( pg == 'pt'){
					window.opener.location.reload();
				}				
    }

   
  
  function validarform(){
	var frm = document.forms.form1;
    <cfoutput>
	<cfif ('#qAcesso.Usu_GrupoAcesso#' eq 'gestores' or '#qAcesso.Usu_GrupoAcesso#' eq 'desenvolvedores')>
		if(frm.recomendacao.value == ''){
			alert('O campo "RECOMENDAÇÕES AO INSPETOR" não pode estar vazio.');
			frm.recomendacao.focus();
			return false;
		}

	<cfelse>
	    if(frm.respInsp.value == ''){
			alert('O campo "RESPOSTA DO INSPETOR" não pode estar vazio.');
			frm.respInsp.focus();
			return false;
		}
	</cfif>	
	</cfoutput>
	document.form1.acao.value='resp';
	return true;
  }

  function validarformSemReavaliar(){
	var frm = document.forms.form1;
    
	if(frm.respInsp.value == ''){
		alert('O campo "RESPOSTA DO INSPETOR" não pode estar vazio.');
		frm.respInsp.focus();
		return false;
	}

	if(confirm('Deseja salvar a sua resposta e devolver o item ao Gestor sem alterações?')){
		document.form1.acao.value='respSemAlteracao';
		return true;
	}else{
		return false;
	}

  }




</script>

</head>

	<!---Verifica se esta inspeção possui algum item não avaliado (todos os NÃO VERIFICADO e os NÂO EXECUTA em que o campo Itn_ValidacaoObrigatoria for igual a 1) --->
<cfquery datasource="#dsn_inspecao#" name="rsVerifValidados">
	SELECT RIP_Resposta, RIP_Recomendacao,Itn_ValidacaoObrigatoria 
	FROM Resultado_Inspecao
	INNER JOIN Unidades ON 
	RIP_Unidade = Und_Codigo
	INNER JOIN Inspecao ON 
	RIP_NumInspecao = INP_NumInspecao AND RIP_Unidade = INP_Unidade
	INNER JOIN Itens_Verificacao ON Itn_Ano = convert(char(4),RIP_Ano) AND 
	INP_Modalidade = Itn_Modalidade and
	Itn_TipoUnidade = Und_TipoUnidade and 
	Itn_NumGrupo = RIP_NumGrupo AND Itn_NumItem = RIP_NumItem
	WHERE ((RTRIM(RIP_Resposta)= 'E' AND Itn_ValidacaoObrigatoria=1) OR RTRIM(RIP_Resposta)= 'V') AND   RTRIM(RIP_Recomendacao) IS NULL AND RIP_NumInspecao='#ninsp#'  
</cfquery>

  <body id="main_body"  >
   <form id="form1" name="form1" onSubmit="" method="post" action="itens_controle_revisliber_reanalise.cfm">
        <input name="ninsp" type="hidden" id="ninsp" value="<cfoutput>#URL.Ninsp#</cfoutput>">
        <input name="ngrup" type="hidden" id="ngrup" value="<cfoutput>#URL.Ngrup#</cfoutput>">
        <input name="nitem" type="hidden" id="nitem" value="<cfoutput>#URL.Nitem#</cfoutput>">
		<input name="pg" type="hidden" id="pg" value="<cfoutput>#URL.pg#</cfoutput>">
		<input name="acao" type="hidden" id="acao" value="">

		<img alt="Ajuda do Item" src="figuras/reavaliar.png" width="45"  border="0" style="position:absolute;left:2px;top:5px"></img>
		<div align="center" style="margin-left:25px;width:700px;margin-top:15px">	
			<div>
				<p style="color:white;text-align:justify;font-size: 14px">Grupo: <cfoutput><strong>#qItemReanalise.Itn_NumGrupo# - #trim(qItemReanalise.Grp_Descricao)#</strong></cfoutput></p>
			
				<p style="color:white;text-align:justify;position:relative;top:-10px;font-size: 12px">Item: <cfoutput><strong>#qItemReanalise.Itn_NumItem# - #trim(qItemReanalise.Itn_Descricao)#</strong></cfoutput></p>
			</div>
			<div  style="background:#0a3865;border:1px solid #fff;font-family:Verdana, Arial, Helvetica, sans-serif">
		    	<label style="color:white"><strong>Parecer Andamento:</strong></label>
				<textarea  <cfif "#qAcesso.Usu_GrupoAcesso#" eq "inspetores">readonly</cfif> id="recomendacao" name="recomendacao" 
				style="background:#fff;color:black;text-align:justify;" cols="85" 
				rows="<cfif '#trim(qOrientacao.RIP_Recomendacao_Inspetor)#' neq ''>6<cfelse>14</cfif>" 
				wrap="VIRTUAL" class="form"><cfoutput>#qOrientacao.RIP_Recomendacao_Inspetor#</cfoutput></textarea>
			</div>


			<div  style="background:#0a3865;border:1px solid #fff;font-family:Verdana, Arial, Helvetica, sans-serif">
		    	<label style="color:white"><strong>Recomendações ao Gestor:</strong></label>
				<textarea  <cfif "#qAcesso.Usu_GrupoAcesso#" eq "inspetores">readonly</cfif> id="recomendacao" name="recomendacao" 
				style="background:#fff;color:black;text-align:justify;" cols="85" 
				rows="<cfif '#trim(qOrientacao.RIP_Recomendacao_Inspetor)#' neq ''>6<cfelse>14</cfif>" 
				wrap="VIRTUAL" class="form"><cfoutput>#qOrientacao.RIP_Recomendacao_Inspetor#</cfoutput></textarea>
			</div>

			
            <cfif '#trim(qOrientacao.RIP_Recomendacao_Inspetor)#' neq ''>
				<div  style="margin-top:20px;background:#0a3865;border:1px solid #fff;font-family:Verdana, Arial, Helvetica, sans-serif">
					<label style="color:white;margin-top:40px"><strong>Resposta do Gestor:</strong></label>
					<textarea  <cfif ('#qAcesso.Usu_GrupoAcesso#' eq 'gestores' or '#qAcesso.Usu_GrupoAcesso#' eq 'desenvolvedores')>readonly</cfif> id="respInsp" name="respInsp" 
					style="background:#fff;color:black;text-align:justify;" cols="85" rows="6" wrap="VIRTUAL" class="form"><cfoutput>#qOrientacao.RIP_Critica_Inspetor#</cfoutput></textarea>
				</div>
            </cfif>

			<cfif ('#qAcesso.Usu_GrupoAcesso#' eq 'gestores' or '#qAcesso.Usu_GrupoAcesso#' eq 'desenvolvedores') and '#qOrientacao.RIP_Recomendacao#' eq 'R'>
				<cfif qInspecaoLiberada.recordCount eq 0 and rsVerifValidados.recordCount eq 0 and qVerifEmReanalise.recordCount eq 1 >
					<input type="submit" class="botao" 
					onclick="if(window.confirm('Atenção! Após a validação desta reanálise, esta Avaliação será liberada e não será possível revisar outros itens.\n\nClique em OK se todos os itens CONFORME. NÃO EXECUTA e NÃO VERIFICADO já tiverem sido revisados, caso contrário, clique em Cancelar e realize a revisão dos itens.')){document.form1.acao.value='validar'}" style="background-color:blue;color:#fff;padding:2px;text-align:center;margin-top:10px;cursor:pointer" 
			        value="Validar Reanálise">	
				<cfelse>
					<input type="submit" class="botao" onClick="document.form1.acao.value='validar'" style="background-color:blue;color:#fff;padding:2px;text-align:center;margin-top:10px;cursor:pointer" 
			        value="Validar Reanálise">	
				</cfif>
            </cfif>

            <cfif ('#qAcesso.Usu_GrupoAcesso#' eq 'gestores' or '#qAcesso.Usu_GrupoAcesso#' eq 'desenvolvedores') and not isDefined('url.cancelar')>
		        	<input type="submit" class="botao" onClick="return validarform();" style="background:red;color:#fff;margin-left:40px;padding:2px;text-align:center;margin-top:10px;cursor:pointer" 
			         value="Enviar para Reanálise do Inspetor"></input>	
			</cfif>
			
			<cfif ('#qAcesso.Usu_GrupoAcesso#' eq 'gestores' or '#qAcesso.Usu_GrupoAcesso#' eq 'desenvolvedores') and isDefined('url.cancelar') and '#url.cancelar#' eq 's'>
					<cfif qInspecaoLiberada.recordCount eq 0 and rsVerifValidados.recordCount eq 0 and qVerifEmReanalise.recordCount eq 1 and '#trim(qOrientacao.RIP_Resposta)#' neq 'N'>
						<input type="submit" class="botao"	onclick="if(window.confirm('Atenção! Após o cancelamento desta reanálise, esta Avaliação será liberada e não será possível revisar outros itens.\n\nClique em OK se todos os itens CONFORME. NÃO EXECUTA e NÃO VERIFICADO já tiverem sido revisados, caso contrário, clique em Cancelar e realize a revisão dos itens.')){document.form1.acao.value='cancelarReanalise'}else{window.close();}" style="background:red;color:#fff;margin-left:40px;padding:2px;text-align:center;margin-top:10px;cursor:pointer"  
						value="Cancelar Reanálise">	
					<cfelse>
						<input type="submit" class="botao" onClick="document.form1.acao.value='cancelarReanalise'" style="background:red;color:#fff;margin-left:40px;padding:2px;text-align:center;margin-top:10px;cursor:pointer" 
						value="Cancelar Reanálise">
					</cfif>
			</cfif>
			
	
			<cfif '#qAcesso.Usu_GrupoAcesso#' eq 'inspetores'>	

			    	<button type="submit" class="botao" onClick="return validarform();" 
				 	style="white-space:normal;width:195px;height:45px;padding:2px;text-align:center;margin-top:10px;cursor:pointer;background-color:blue;color:#fff" >
			        Salvar Resposta para o Gestor <br>e iniciar a Reanálise</button>

					<button type="submit" class="botao" onClick="return validarformSemReavaliar();" 
				 	style="margin-left:40px;white-space:normal;width:195px;height:45px;padding:2px;text-align:center;margin-top:10px;cursor:pointer;background-color:red;color:#fff" >
			        Salvar Resposta para o Gestor <br>sem realizar alterações no item</button>	
			</cfif>


               

			   <input type="button" class="botao" style="padding:2px;text-align:center;margin-left:40px;cursor:pointer" value="Fechar" onclick="window.close();"
		


		</div>
	 </form>
	</body>
</html>





	

