<cfprocessingdirective pageEncoding ="utf-8"/> 
<cfinclude template="../../../parametros.cfm">

<cfinvoke component="#vRelatorio#.GeraRelatorio.gerador.ctrl.controller"
	method="geraMatriculaInspetor" returnvariable="qryInspetor">
</cfinvoke>

<cfinvoke component="#vRelatorio#.GeraRelatorio.gerador.ctrl.controller"
	method="geraPapelTrabalho" returnvariable="qryPapelTrabalho">
</cfinvoke>

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_DR, RTRIM(LTRIM(Usu_GrupoAcesso)) AS Usu_GrupoAcesso, Usu_Matricula, Usu_Email, Usu_Apelido, Usu_Coordena 
	from usuarios 
	where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>


<!---  --->
<cfoutput>
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
</cfoutput>
<!---  --->
	<cfset qtItens = qryPapelTrabalho.recordcount>

  <cfquery name="rsSituacoes" datasource="#dsn_inspecao#">
      SELECT Pos_Situacao_Resp, Pos_NumGrupo, Pos_NumItem, Pos_NCISEI, STO_Descricao, STO_Cor FROM ParecerUnidade
      INNER JOIN Situacao_Ponto ON STO_Codigo = Pos_Situacao_Resp
      WHERE  Pos_Unidade ='#qryPapelTrabalho.RIP_Unidade#' and Pos_Inspecao='#qryPapelTrabalho.INP_NumInspecao#'
      ORDER BY Pos_Situacao_Resp, Pos_NumGrupo, Pos_NumItem
  </cfquery>

<cfquery name="rsRelev" datasource="#dsn_inspecao#">
	SELECT VLR_Fator, VLR_FaixaInicial, VLR_FaixaFinal
	FROM ValorRelevancia
	WHERE VLR_Ano = '#right(qryPapelTrabalho.INP_NumInspecao,4)#'
</cfquery>


  <cfquery name = "rsQuatEmRevisao" dbtype = "query" >
      SELECT count(Pos_Situacao_Resp) as quantEmRevisao from rsSituacoes
      WHERE Pos_Situacao_Resp in (0,11)
  </cfquery>



  <cfquery name="rsItemEmReanalise" datasource="#dsn_inspecao#">
        SELECT RIP_Resposta, RIP_NumGrupo, RIP_NumItem FROM Resultado_Inspecao 
        WHERE RTRIM(RIP_Recomendacao)='S' AND RIP_NumInspecao='#qryPapelTrabalho.INP_NumInspecao#' 
  </cfquery>



  <cfquery name="rsItemReanalisado" datasource="#dsn_inspecao#">
        SELECT RIP_Resposta, RIP_NumGrupo, RIP_NumItem FROM Resultado_Inspecao 
        WHERE RTRIM(RIP_Recomendacao)='R' AND RIP_NumInspecao='#qryPapelTrabalho.INP_NumInspecao#' 
  </cfquery>



  <cfquery datasource="#dsn_inspecao#" name="rsVerifValidados">
    SELECT RIP_Resposta, RIP_Recomendacao,Itn_ValidacaoObrigatoria 
	FROM ((Unidades INNER JOIN Inspecao ON Und_Codigo = INP_Unidade) 
INNER JOIN Resultado_Inspecao ON (INP_NumInspecao = RIP_NumInspecao) AND 
(INP_Unidade = RIP_Unidade)) 
INNER JOIN Itens_Verificacao ON (Itn_Ano = convert(char(4),RIP_Ano)) and (RIP_NumItem = Itn_NumItem) 
AND (RIP_NumGrupo = Itn_NumGrupo) AND (Und_TipoUnidade = Itn_TipoUnidade) AND
 (INP_Modalidade = Itn_Modalidade) 
    WHERE (((RTRIM(RIP_Resposta)= 'E' AND Itn_ValidacaoObrigatoria=1) OR RTRIM(RIP_Resposta)= 'V')) AND (RTRIM(RIP_Recomendacao) is NULL) AND RIP_NumInspecao='#qryPapelTrabalho.INP_NumInspecao#' and RIP_Unidade='#qryPapelTrabalho.RIP_Unidade#' 
  </cfquery>


  <cfset emReavaliacaoReavaliado = "#rsItemEmReanalise.recordcount#" + "#rsItemReanalisado.recordcount#" >

<!---Inspeções NA = não avaliadas, ER = em reavaliação, RA =reavaliado, CO = concluída--->
  <cfquery name="rsInspecaoNaoFinalizada" datasource="#dsn_inspecao#">
        SELECT INP_Situacao, INP_DtUltAtu, Pos_Situacao_Resp  FROM Inspecao
        LEFT JOIN  ParecerUnidade ON INP_NumInspecao = Pos_Inspecao
        WHERE LTRIM(INP_Situacao)<>'CO' 
         and INP_Unidade ='#qryPapelTrabalho.RIP_Unidade#' and INP_NumInspecao='#qryPapelTrabalho.INP_NumInspecao#'
  </cfquery>


  <!--- Valida itens individuais (todos os NÃO VERIFICADO e os NÂO EXECUTA em que o campo Itn_ValidacaoObrigatoria for igual a 1 ) --->
  <cfif isDefined("form.acao") and '#form.acao#' is 'validarItem'>
	
	<cfset RIPCaractvlr = 'NAO QUANTIFICADO'>
	<cfif listfind('#qryPapelTrabalho.Itn_PTC_Seq#','10')>
		<cfset RIPCaractvlr = 'QUANTIFICADO'>
	</cfif>	
    <cfquery datasource="#dsn_inspecao#">
          UPDATE Resultado_Inspecao SET RIP_Recomendacao = 'V', RIP_Caractvlr = '#RIPCaractvlr#'
          WHERE RIP_Unidade = '#qryPapelTrabalho.RIP_Unidade#'	and RIP_NumInspecao ='#qryPapelTrabalho.INP_NumInspecao#'
                and RIP_NumGrupo ='#form.grupo#' and RIP_NumItem='#form.item#'
    </cfquery>
   
   

    <!---Início do processo de liberação da avaliação--->
			    <!---Veirifica se esta inspeção possui algum item Em Revisão --->	
				<cfquery name="qInspecaoLiberada" datasource="#dsn_inspecao#">
					SELECT * FROM ParecerUnidade 
					WHERE Pos_Inspecao='#qryPapelTrabalho.INP_NumInspecao#' AND Pos_Situacao_Resp = 0
				</cfquery>
				<!---Veirifica se esta inspeção possui algum item em reanálise --->
				<cfquery datasource="#dsn_inspecao#" name="qVerifEmReanalise">
					SELECT RIP_Resposta, RIP_Recomendacao FROM Resultado_Inspecao 
					WHERE (RTRIM(RIP_Recomendacao)='S' OR RTRIM(RIP_Recomendacao)='R') and RIP_NumInspecao='#qryPapelTrabalho.INP_NumInspecao#' 
				</cfquery>
				<!---Verifica se esta inspeção possui algum item não avaliado (todos os NÃO VERIFICADO e os NÂO EXECUTA em que o campo Itn_ValidacaoObrigatoria for igual a 1) --->
				<cfquery datasource="#dsn_inspecao#" name="qVerifValidados">
					SELECT RIP_Resposta, RIP_Recomendacao 
					FROM ((Unidades INNER JOIN Inspecao ON Und_Codigo = INP_Unidade) 
INNER JOIN Resultado_Inspecao ON (INP_NumInspecao = RIP_NumInspecao) AND 
(INP_Unidade = RIP_Unidade)) 
INNER JOIN Itens_Verificacao ON (Itn_Ano = convert(char(4),RIP_Ano)) and (RIP_NumItem = Itn_NumItem) 
AND (RIP_NumGrupo = Itn_NumGrupo) AND (Und_TipoUnidade = Itn_TipoUnidade) AND
 (INP_Modalidade = Itn_Modalidade) 
					WHERE ((RTRIM(RIP_Resposta)= 'E' AND Itn_ValidacaoObrigatoria=1) OR RTRIM(RIP_Resposta)= 'V') AND   RTRIM(RIP_Recomendacao) IS NULL AND RIP_NumInspecao='#qryPapelTrabalho.INP_NumInspecao#' and RIP_Unidade='#qryPapelTrabalho.RIP_Unidade#' 
				</cfquery>
   
				<!---Início - Se não existirem itens em revisão e não existirem itens em reavaliação,
				     inicia o processo de liberação de todos os itens--->	
					<cfif qInspecaoLiberada.recordCount eq 0 and qVerifEmReanalise.recordCount eq 0 and qVerifValidados.recordCount eq 0>

						<!---Salva a matricula do gestor na tabela Inspecao para sinalisar o gestor que liberou a verificação --->
						<cfquery datasource="#dsn_inspecao#">
							UPDATE Inspecao SET INP_Situacao = 'CO', INP_UserName = '#CGI.REMOTE_USER#', INP_DtEncerramento = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#, INP_DTUltAtu = CONVERT(DATETIME, getdate(), 103)
							WHERE INP_NumInspecao ='#qryPapelTrabalho.INP_NumInspecao#'
						</cfquery>
						
						<cfquery name="rs11" datasource="#dsn_inspecao#">
							SELECT RIP_REINCINSPECAO, RIP_Falta, RIP_Sobra, Und_TipoUnidade, Und_Centraliza, Itn_TipoUnidade, Pos_Unidade, Pos_NumGrupo, Pos_NumItem, Pos_Area, Pos_NomeArea, Itn_Pontuacao, Itn_Classificacao, Itn_PTC_Seq
							FROM (((Inspecao 
							INNER JOIN Resultado_Inspecao ON (INP_NumInspecao = RIP_NumInspecao) AND (INP_Unidade = RIP_Unidade)) 
							INNER JOIN ParecerUnidade ON (RIP_NumItem = Pos_NumItem) AND (RIP_NumGrupo = Pos_NumGrupo) AND (RIP_NumInspecao = Pos_Inspecao) AND (RIP_Unidade = Pos_Unidade)) 
							INNER JOIN Itens_Verificacao ON (convert(char(4),RIP_Ano) = Itn_Ano) AND (INP_Modalidade = Itn_Modalidade) AND (Pos_NumItem = Itn_NumItem) AND (Pos_NumGrupo = Itn_NumGrupo)) 
							INNER JOIN Unidades ON (Und_TipoUnidade = Itn_TipoUnidade) AND (Pos_Unidade = Und_Codigo)
							WHERE Pos_Inspecao='#qryPapelTrabalho.INP_NumInspecao#' AND Pos_Situacao_Resp = 11
						</cfquery>
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
<!---  --->	
								<!--- inicio classificacao do ponto --->
								<cfset composic = rs11.Itn_PTC_Seq>	
								<cfset ItnPontuacao = rs11.Itn_Pontuacao>
								<cfset ClasItem_Ponto = ucase(trim(rs11.Itn_Classificacao))>
													
								<cfset impactosn = 'N'>
								<cfif left(composic,2) eq '10'>
									<cfset impactosn = 'S'>
								</cfif>
								<!--- <cfset pontua = ItnPontuacao> --->
								<cfset fator = 1>
								<cfif impactosn eq 'S'>
									 <cfset somafaltasobra = rs11.RIP_Falta>
									 <cfif (rs11.Pos_NumItem eq 1 and (rs11.Pos_NumGrupo eq 53 or rs11.Pos_NumGrupo eq 72 or rs11.Pos_NumGrupo eq 214 or rs11.Pos_NumGrupo eq 284))>
										<cfset somafaltasobra = somafaltasobra + rs11.RIP_Sobra>
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
											WHERE TUP_Ano = '#right(qryPapelTrabalho.INP_NumInspecao,4)#' AND TUP_Tun_Codigo = #rs11.Itn_TipoUnidade#
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
								<cfif len(trim(rs11.RIP_REINCINSPECAO)) gt 0 and ClasItem_Ponto eq 'LEVE'>
									<cfset ClasItem_Ponto = 'MEDIANO'> 
								</cfif>
<!---  --->						
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
									, Pos_PontuacaoPonto=#ItnPontuacao#
									, Pos_ClassificacaoPonto='#ClasItem_Ponto#'
									, Pos_Sit_Resp_Antes = 11
									WHERE Pos_Inspecao='#qryPapelTrabalho.INP_NumInspecao#' and Pos_NumGrupo = #rs11.Pos_NumGrupo# and Pos_NumItem = #rs11.Pos_NumItem# and Pos_Situacao_Resp = 11
								</cfquery>
								<!--- Inserindo dados dados na tabela Andamento --->
								<cfset andparecer = #auxposarea#  & " --- " & #auxnomearea#>
								<cfquery datasource="#dsn_inspecao#">
									insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, and_Parecer, And_Area) 
									values ('#qryPapelTrabalho.INP_NumInspecao#', '#rs11.Pos_Unidade#', #rs11.Pos_NumGrupo#, #rs11.Pos_NumItem#, convert(char, getdate(), 102), '#CGI.REMOTE_USER#', 14, CONVERT(char, GETDATE(), 108), '#andparecer#', '#auxposarea#')
								</cfquery>
							</cfloop>
                     
						<!---Fim -Se existirem itens em liberação, executa a rotina para mudança do status de todos os itens
							em liberação para não respondido--->

						<!--- Início - e-mail automático por unidade --->
							<cfquery name="rsEmail" datasource="#dsn_inspecao#">
								SELECT Pos_Area, Pos_NomeArea, Pos_Unidade, Und_TipoUnidade, Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Und_CodReop, INP_DtInicInspecao
								FROM Inspecao INNER JOIN (Unidades INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade) ON (INP_NumInspecao = Pos_Inspecao) AND (INP_Unidade = Pos_Unidade)
								WHERE (Pos_Unidade = '#qryPapelTrabalho.RIP_Unidade#') AND (Pos_Inspecao = '#qryPapelTrabalho.INP_NumInspecao#') AND (Pos_Situacao_Resp = 14)
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
								    

									<cfset sdestina = #sdestina# & ';' & #qAcesso.Usu_Email# & ';' & 'gilvanm@correios.com.br'>
								
									<cfif findoneof("@", trim(sdestina)) eq 0>
										<cfset sdestina = "gilvanm@correios.com.br">
									</cfif>
			 							
									<cfset assunto = 'Relatorio de Controle Interno - ' & #trim(rsEmail.Und_Descricao)# & ' - Avaliacao de Controle Interno ' & '#qryPapelTrabalho.INP_NumInspecao#'>
									<cfmail from="SNCI@correios.com.br" to="#sdestina#" subject="#assunto#" type="HTML">
										Mensagem automática. Não precisa responder!<br><br>
										<strong>
										Prezado(a) Gerente do(a) #trim(Ucase(rsEmail.Und_Descricao))#, informamos que está disponível na intranet o Relatório de Controle Interno: N° '#qryPapelTrabalho.INP_NumInspecao#', realizada nessa Unidade na Data: #dateformat(rsEmail.INP_DtInicInspecao,"dd/mm/yyyy")#. <br><br><br>

									&nbsp;&nbsp;&nbsp;Solicitamos acessá-lo para registro de sua resposta, conforme orientações a seguir:<br><br>

									&nbsp;&nbsp;&nbsp;a) Informar a Justificativa para ocorrência da falha: o que ocasionou o Problema (CAUSA); <br>

									&nbsp;&nbsp;&nbsp;b) Informar o Plano de Ações adotado para regularização da falha detectada, com prazo de implementação;<br>

									&nbsp;&nbsp;&nbsp;c) Anexar no sistema os Comprovantes de regularização da situação encontrada e/ou das Ações implementadas (em PDF).<br><br>

									&nbsp;&nbsp;&nbsp;Registrar a resposta no Sistema Nacional de Controle Interno - SNCI  num prazo de dez (10) dias úteis, contados a partir da data de entrega do Relatório. <br>
									&nbsp;&nbsp;&nbsp;O Não cumprimento desse prazo ensejará comunicação ao órgão subordinador dessa unidade.<br><br>

									&nbsp;&nbsp;&nbsp;Acesse o SNCI endereço: 'http://intranetsistemaspe/snci/rotinas_inspecao.cfm' ou clique no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">Relatório de Controle Interno.</a><br><br>

									&nbsp;&nbsp;&nbsp;Atentar para as orientações deste e-mail para registro de sua manifestação no SNCI. Respostas incompletas serão devolvidas para complementação. <br><br>

									&nbsp;&nbsp;&nbsp;Em caso de dúvidas, entrar em contato com a Equipe de Controle Interno localizada na SE, por meio do endereço eletrônico:  #qAcesso.Usu_Email#.<br><br>

									<table>
									<tr>
									<td><strong>Unidade : #rsEmail.Pos_Unidade# - #rsEmail.Und_Descricao#</strong></td>
									</tr>
									<tr>
									<td><strong>Relatório: #rsEmail.Pos_Inspecao#</strong></td>
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
						WHERE Pos_Inspecao='#qryPapelTrabalho.INP_NumInspecao#' AND Pos_Situacao_Resp = 14
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
								VALUES ('#qNaoRespondido.Pos_Inspecao#', '#qNaoRespondido.Pos_Unidade#', #qNaoRespondido.Pos_NumGrupo#, #qNaoRespondido.Pos_NumItem#, convert(char, getdate(), 102), '#CGI.REMOTE_USER#', 14, CONVERT(char, GETDATE(), 108),'#qryPapelTrabalho.RIP_Unidade#')
							</cfquery>
						</cfif>
					</cfoutput>
				<!--- fim Verificaçaõ dos registros que estão na situação 14(Não Respondido) na tabela ParecerUnidade --->
					
			<!---Fim do prcesso de liberação da avaliação--->


    <script language="javascript" >
        alert('Item validado com sucesso!');
        window.open(window.location,'_self');
    </script>
    



  </cfif>

  <!--- Valida todos os itens de uma avaliação sem itens NC --->
  <cfif isDefined("form.acao") and '#form.acao#' is 'validarSemNC'>
	  <cfset RIPCaractvlr = 'NAO QUANTIFICADO'>
	  <cfif listfind('#qryPapelTrabalho.Itn_PTC_Seq#','10')>
		<cfset RIPCaractvlr = 'QUANTIFICADO'>
	  </cfif>	
      <cfquery datasource="#dsn_inspecao#">
          UPDATE Resultado_Inspecao SET RIP_Recomendacao = 'V', RIP_Caractvlr = '#RIPCaractvlr#'
          WHERE RIP_Unidade = '#qryPapelTrabalho.RIP_Unidade#'	and RIP_NumInspecao ='#qryPapelTrabalho.INP_NumInspecao#'
      </cfquery>
      <cfquery datasource="#dsn_inspecao#">
          UPDATE Inspecao SET INP_Situacao = 'CO', INP_UserName = '#CGI.REMOTE_USER#', INP_DTUltAtu = CONVERT(DATETIME, getdate(), 103)
          WHERE INP_Unidade = '#qryPapelTrabalho.RIP_Unidade#'	and INP_NumInspecao ='#qryPapelTrabalho.INP_NumInspecao#'
      </cfquery>
      <cfquery datasource="#dsn_inspecao#">
          UPDATE ProcessoParecerUnidade SET Pro_Situacao = 'EN', Pro_DtEncerr = convert(char, getdate(), 102), Pro_userName = '#CGI.REMOTE_USER#', Pro_dtultatu = CONVERT(DATETIME, getdate(), 103)
          WHERE Pro_Unidade = '#qryPapelTrabalho.RIP_Unidade#'	and Pro_Inspecao ='#qryPapelTrabalho.INP_NumInspecao#'
      </cfquery>
      
      <script language="javascript" >
        window.opener.location.reload() ;
        alert('Avaliação sem Itens "NÃO CONFORME" Validada com sucesso!');
        <cfoutput>
          window.open(window.location,'_self');
        </cfoutput>
      </script>
     
  </cfif>

  
<!---Veirifica se esta inspeção possui algum item Em Revisão --->	
	<cfquery name="qInspecaoEmRevisao" datasource="#dsn_inspecao#">
		SELECT * FROM ParecerUnidade 
		WHERE Pos_Inspecao='#qryPapelTrabalho.INP_NumInspecao#' AND Pos_Situacao_Resp = 0
	</cfquery>

  <cfset semNCvalidado = false>
   <!---Verifica se é uma verifcação não tem itens não conforme e se foi validada--->
  <cfquery datasource="#dsn_inspecao#" name="rsSemNC" >
			SELECT Count(RIP_NumInspecao) as total, Count(CASE WHEN LTRIM(RTRIM(RIP_Recomendacao))='V' THEN 1 END) AS validado
      ,Count(CASE WHEN LTRIM(RTRIM(RIP_Resposta))='N' THEN 1 END) AS itemNC, Count(RIP_MatricAvaliador) as totalAvaliadores
      FROM  Resultado_Inspecao
			WHERE RIP_Unidade = '#qryPapelTrabalho.RIP_Unidade#' and RIP_NumInspecao ='#qryPapelTrabalho.INP_NumInspecao#'  
  </cfquery>


  <!---FIM - Verifica se é uma verificação sem itens não conforme--->
  <cfif "#rsSemNC.total#" eq "#rsSemNC.validado#" >
    <cfset semNCvalidado = true>
  </cfif>

 <!---  <cfquery name="rsLiberadaValidadaPor" datasource="#dsn_inspecao#">
    SELECT Fun_Matric, Fun_Nome FROM Funcionarios
    WHERE Fun_Matric = '#qryPapelTrabalho.INP_Username#'
  </cfquery> --->
   <cfquery name="rsLiberadaValidadaPor" datasource="#dsn_inspecao#">
	SELECT Usu_Matricula, Usu_Apelido
	FROM Usuarios
	WHERE Usu_Login = '#qryPapelTrabalho.INP_Username#'
  </cfquery>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="../../../css.css" rel="stylesheet" type="text/css" />
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<cfif structKeyExists(url,'pg') and '#url.pg#' eq 'controle' and "#rsItemEmReanalise.recordcount#" neq 0>
    <meta http-equiv="refresh" content="60">
</cfif>

<style type="text/css">
<!--
.style2 {font-size: 14}
-->
</style>

  <script language="javascript" >
   
    //captura a posição do scroll (usado nos botões que chamam outras páginas)
    //e salva no sessionStorage
    function capturaPosicaoScroll() {
      sessionStorage.setItem('scrollpos', document.body.scrollTop);
    }

    //após o onload recupera a posição do scroll armazenada no sessionStorage e reposiciona-o conforme última localização
    window.onload = function () {
      var scrollpos = sessionStorage.getItem('scrollpos');
      if (scrollpos) window.scrollTo(0, scrollpos);
      sessionStorage.setItem('scrollpos', '0');
      capturaPosicaoScroll();
    };

    //ao fechar, atualiza a página de controle de verificações
    window.onbeforeunload = function () {
      window.opener.location.reload();
    }

    function aguarde(t) {

      if (t !== undefined) {
        topo = 30 + document.getElementById(t).offsetTop;
      } else {
        topo = '200';
      }

      if (document.getElementById("aguarde").style.visibility == "visible") {
        document.getElementById("aguarde").style.visibility = "hidden";
        document.getElementById("main_body").style.cursor = 'auto';
      } else {
        document.getElementById("main_body").style.cursor = 'progress';
        document.getElementById("aguarde").style.visibility = "visible";
        piscando();

      }

      document.getElementById("imgAguarde").style.top = topo + 'px';
    }


    function abrirPopup(url, w, h) {

      var newW = w + 100;
      var newH = h + 100;
      var left = (screen.width - newW) / 2;
      var top = (screen.height - newH) / 2;
      var newwindow = window.open(url, '_blank', 'width=' + newW + ',height=' + newH + ',left=' + left + ',top=' + top + ',scrollbars=yes');
      newwindow.resizeTo(newW, newH);

      //posiciona o popup no centro da tela
      newwindow.moveTo(left, top);
      newwindow.focus();

    }

    //para botão voltar ao topo
    window.onscroll = function () {
      scrollFunction()
    };

    window.requestAnimFrame = (function () {
      return window.requestAnimationFrame ||
        window.webkitRequestAnimationFrame ||
        window.mozRequestAnimationFrame ||
        function (callback) {
          window.setTimeout(callback, 1000 / 60);
        };
    })();

    function scrollToY(scrollTargetY, speed, easing) {
      // scrollTargetY: the target scrollY property of the window
      // speed: time in pixels per second
      // easing: easing equation to use

      var scrollY = window.scrollY || document.documentElement.scrollTop,
        scrollTargetY = scrollTargetY || 0,
        speed = speed || 2000,
        easing = easing || 'easeOutSine',
        currentTime = 0;

      // min time .1, max time .8 seconds
      var time = Math.max(.1, Math.min(Math.abs(scrollY - scrollTargetY) / speed, .8));

      var easingEquations = {
        easeOutSine: function (pos) {
          return Math.sin(pos * (Math.PI / 2));
        },
        easeInOutSine: function (pos) {
          return (-0.5 * (Math.cos(Math.PI * pos) - 1));
        },
        easeInOutQuint: function (pos) {
          if ((pos /= 0.5) < 1) {
            return 0.5 * Math.pow(pos, 5);
          }
          return 0.5 * (Math.pow((pos - 2), 5) + 2);
        }
      };

      // add animation loop
      function tick() {
        currentTime += 1 / 60;

        var p = currentTime / time;
        var t = easingEquations[easing](p);

        if (p < 1) {
          requestAnimFrame(tick);

          window.scrollTo(0, scrollY + ((scrollTargetY - scrollY) * t));
        } else {
          window.scrollTo(0, scrollTargetY);
        }

      }

      // call it once to get started
      tick();
    }

    function scrollFunction() {
      capturaPosicaoScroll();
      if (document.body.scrollTop > 20 || document.documentElement.scrollTop > 20) {
        document.getElementById("subDiv").style.display = "block";
      } else {
        document.getElementById("subDiv").style.display = "none";
      }

    }
    //fim script botão voltar ao topo


  </script>


</head>
<body id="main_body" style="background:#fff" >
<cfset form.acao = ''>
<div id="aguarde" name="aguarde" align="center"  style="width:100%;height:200%;top:0px;left:0px; background:transparent;
filter:progid:DXImageTransform.Microsoft.gradient(startColorstr=#7F86b2ff,endColorstr=#7F86b2ff);
z-index:1000;visibility:hidden;position:absolute;" >		
		 <img id="imgAguarde" name="imgAguarde" src="figuras/aguarde.png" width="100px"  border="0" style="position:absolute;"></img>
</div>
  <form id="formPT"  name="formPT" method="post">
      <input type="hidden" id="acao" name="acao" value="">
      <input type="hidden" id="grupo" name="grupo" value="">
      <input type="hidden" id="item" name="item" value="">

      <div id="mainDiv" align="right" class="noprint">
        <div id="subDiv">
        <a onClick="scrollToY(0, 10000, 'easeInOutSine');" style="cursor:pointer"><img   alt="Ir para o topo da página" src="../../../figuras/topo.png" width="50"   border="0" ></img>
        <br>
        <span style="background-color:#fff;color:darkblue;position:relative;left:-8px;top:-7px">Topo</span></a>
        </div>
      </div>
      <table border="0" widtd="100%">
        <cfif qryPapelTrabalho.recordcount is 0>
        <tr>
          <td  valign="baseline" bordercolor="999999" bgcolor="" class="red_titulo"><div align="center"><span class="style2">Caro colaborador n&atilde;o h&aacute; registros para Avaliação solicitada</span></div></td>
        </tr>
      </table>
        <cfabort>
        </cfif>
        <tr>
          <td widtd="22%" rowspan="2"><div align="left"></div></td>
        </tr>
        <table widtd="100%" border="0" cellspacing="4">
          <tr>
            <td colspan="4" valign="top" bordercolor="999999" bgcolor="" scope="row"></td>
          </tr>
          <tr>
            <td colspan="2" rowspan="2" valign="top" bordercolor="999999" bgcolor="" scope="row"><span class="labelcell"><img src="../../geral/img/logoCorreios.gif" alt="Logo ECT" width="148" height="33" align="left" /></span></td>
            <td colspan="7" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left"><span class="style2">DEPARTAMENTO DE CONTROLE INTERNO</span></div></td>
          </tr>
          <tr>
            <td colspan="7" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left"> <span class="style2">PAPEL DE TRABALHO</span> </div></td>
          </tr>
          <tr>
            <td width="4" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left" class="labelcell"></div></td>
            <th width="155" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left">Superintend&ecirc;ncia:</div></th>
            <td colspan="7" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="justify"><cfoutput>#qryPapelTrabalho.Dir_Descricao#</cfoutput></div></td>
          </tr>
           <tr>
            <td widtd="1%" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left" class="labelcell"></div></td>
            <th valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left">Unidade:</div></th>
            <td width="450" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="justify"><cfoutput>#qryPapelTrabalho.Und_Descricao#</cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
			<cfset auxclaini = qryPapelTrabalho.TNC_ClassifInicio>
			<cfset auxclaatu = qryPapelTrabalho.TNC_ClassifAtual>			
            <td width="663" colspan="6" valign="top" bordercolor="999999" bgcolor="" scope="row">
			<table width="100%" border="0">
              <tr>
                <td width="25%" bordercolor="999999"> <div align="center">Classifica&ccedil;&atilde;o Inicial:</div></td>
                <td width="25%" bordercolor="999999"><div align="left"><cfoutput>#auxclaini#</cfoutput></div></td>
                <td width="23%" bordercolor="999999"> <div align="center">Classifica&ccedil;&atilde;o Atual:</div></td>
                <td width="27%" bordercolor="999999"><div align="left"><cfoutput>#auxclaatu#</cfoutput></div></td>
              </tr>
            </table>
			</td>
          </tr> 
		   <tr>
            <td valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left" class="labelcell"></div></td>
            <th valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left">Per&iacute;odo do Relat&oacute;rio:</div></th>
            <td colspan="7" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="justify"><cfoutput>#DateFormat(qryPapelTrabalho.INP_DtInicInspecao,'dd/mm/yyyy')#</cfoutput>
                    <label class="fieldcell"> a </label>
                    <cfoutput>#DateFormat(qryPapelTrabalho.INP_DtFimInspecao,'dd/mm/yyyy')#</cfoutput></div></td>
          </tr>
          <cfset Num_Insp = Left(qryPapelTrabalho.INP_NumInspecao,2) & '.' & Mid(qryPapelTrabalho.INP_NumInspecao,3,4) & '/' & Right(qryPapelTrabalho.INP_NumInspecao,4)>
          <tr>
            <td valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left" class="labelcell"></div></td>
            <th valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left">N&ordm; do Relat&oacute;rio:</div></th>
            <td colspan="7" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="justify"><cfoutput>#Num_Insp#</cfoutput>
                    <cfif '#rsSituacoes.recordCount#' neq 0 and '#rsSemNC.totalAvaliadores#' neq 0>
                      <cfif '#rsInspecaoNaoFinalizada.recordcount#' eq 0 and rsVerifValidados.recordcount eq 0 and rsQuatEmRevisao.recordcount eq 0>
                        <cfset dataHora = '#DateFormat(qryPapelTrabalho.INP_DtUltAtu,"DD/MM/YYYY")#'>
                        <span style="font-family:arial;font-size:12px;color:blue"><strong>AVALIA&Ccedil;&Atilde;O LIBERADA</strong></span> <span style="font-family:arial;font-size:10px;color:blue"> (por: <cfoutput>#rsLiberadaValidadaPor.Usu_Apelido# - em: #dataHora#)</cfoutput></span>
                        <cfif structKeyExists(url,'pg') and '#url.pg#' eq 'controle' >
                          <script>
                                  var mens = 'Avalia&ccedil;&atilde;o de Controle liberada para Manifesta&ccedil;&atilde;o da unidade:\n<cfoutput>#qryPapelTrabalho.Und_Descricao#</cfoutput>\n\nLibera&ccedil;&atilde;o realizada por:\n<cfoutput>#trim(rsLiberadaValidadaPor.Usu_Apelido)#</cfoutput> em <cfoutput>#dataHora#</cfoutput>.'; 
                                    alert(mens);
                                </script>
                        </cfif>
                        <cfelse>
                        <span class="noprint" style="font-family:arial;font-size:12px;color:red"><strong>AVALIA&Ccedil;&Atilde;O N&Atilde;O LIBERADA</strong></span> <span class="noprint" style="font-family:arial;font-size:10px;color:red"> (Ainda existem itens EM REVIS&Atilde;O ou EM REAN&Aacute;LISE, REANALISADOS, N&Atilde;O VERIFICADO ou N&Atilde;O EXECUTA sem valida&ccedil;&atilde;o.)</span>
                      </cfif>
                    </cfif>
                    <cfif '#semNCvalidado#' is false and '#emReavaliacaoReavaliado#' eq 0 and '#rsSemNC.itemNC#' eq 0 and "#rsSemNC.totalAvaliadores#" neq 0>
                      <span class="noprint" style="font-family:arial;font-size:12px;color:red"><strong>AVALIAÇÃO SEM ITENS "N&Atilde;O CONFORME"</strong></span> <span class="noprint" style="font-family:arial;font-size:12px;color:red;"> - Prezado Gestor, ap&oacute;s confer&ecirc;ncia de todos os itens desta Avaliação, valide-a clicando no bot&atilde;o no final desta p&aacute;gina.</span>
                      <cfelse>
                      <cfif '#rsSemNC.itemNC#' eq 0 and '#semNCvalidado#' is true and "#rsSemNC.totalAvaliadores#" neq 0>
                        <span style="font-family:arial;font-size:12px;color:blue"><strong>AVALIAÇÃO SEM ITENS "N&Atilde;O CONFORME" VALIDADA</strong></span> <span style="font-family:arial;font-size:10px;color:blue"> (por: <cfoutput>#rsLiberadaValidadaPor.Usu_Apelido#)</cfoutput></span>
                      </cfif>
                    </cfif>
                    <cfif #rsItemEmReanalise.recordcount# neq 0>
                      <div style="margin-bottom:10px"><span style="font-family:arial;margin-right:2px;background:red;color:#fff;padding:3px;font-size:14px;">EM REAN&Aacute;LISE PELO INSPETOR:&nbsp;</span><cfoutput query="rsItemEmReanalise">
                          <button class="botaoCadReanalise botaoPT" style="position:relative;top:3px" onClick="location.href='###rsItemEmReanalise.RIP_NumGrupo#.#rsItemEmReanalise.RIP_NumItem#'" type="button">#rsItemEmReanalise.RIP_NumGrupo#.#rsItemEmReanalise.RIP_NumItem#</button>
                      </cfoutput></div>
                    </cfif>
                    <cfif ('#qAcesso.Usu_GrupoAcesso#' eq 'gestores' or '#qAcesso.Usu_GrupoAcesso#' eq 'desenvolvedores') and #rsItemReanalisado.recordcount# neq 0>
                      <div  class="noprint" ><span style="font-family:arial;margin-right:2px;background:darkred;color:#fff;padding:4px;font-size:14px;">REANALISADO PELO INSPETOR:&nbsp;</span><cfoutput query="rsItemReanalisado">
                          <button class="botaoCadReanalisado botaoPT" style="position:relative;top:2px;padding:2px" onClick="location.href='###rsItemReanalisado.RIP_NumGrupo#.#rsItemReanalisado.RIP_NumItem#'" type="button">#rsItemReanalisado.RIP_NumGrupo#.#rsItemReanalisado.RIP_NumItem#</button>
                      </cfoutput> </div>
                    </cfif>
            </div></td>
          </tr>
          <tr>
            <td colspan="10" valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</td>
          </tr>
          <tr>
            <td valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</td>
            <td colspan="9" valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</td>
          </tr>
          <tr>
            <td colspan="10" valign="top" bordercolor="999999" bgcolor="CCCCCC" scope="row"><div align="left">&nbsp;</div></td>
          </tr>
          <cfset numGrav = 0>
          <cfset muitoGrav = 0>
          <cfset CP = 0>
          <cfoutput query="qryPapelTrabalho" group="Grp_Codigo">
            <tr>
              <td valign="top" bordercolor="999999" bgcolor="" scope="row"><label class="labelcell"> </label>
                  <div align="left"></div></td>
              <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">GRUPO: #Grp_Codigo#</div></th>
              <td colspan="7" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="justify"><strong>#Grp_Descricao#</strong></div></td>
            </tr>
            <cfoutput>
              <tr>
                <td  colspan="10" valign="top" bordercolor="999999" bgcolor=""  scope="row">&nbsp;</td>
              </tr>
              <tr>
                <td valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</td>
                <!---   ID para âncora     --->
				<cfset grp = Grp_Codigo>
				<cfset Ite = Itn_NumItem>
                <th valign="top" bordercolor="999999" bgcolor="" scope="row"><div id="#Grp_Codigo#.#Itn_NumItem#" align="left">Item: #grp#.#ite#</div></th>
                <td colspan="7" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left"><strong>#Itn_Descricao#</strong></div></td>
              </tr>
             <tr>
			 <cfset auxpontua = qryPapelTrabalho.Itn_Pontuacao>
			 <cfset auxclassif = qryPapelTrabalho.Itn_Classificacao>
			 <cfif len(trim(qryPapelTrabalho.Pos_ClassificacaoPonto)) gt 0>
				 <cfset auxpontua = qryPapelTrabalho.Pos_PontuacaoPonto>
				 <cfset auxclassif = qryPapelTrabalho.Pos_ClassificacaoPonto>
			 </cfif>
                <td valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</td>
                <!---   ID para âncora     --->
                <th valign="top" bordercolor="999999" bgcolor="" scope="row"><div id="#Grp_Codigo#.#Itn_NumItem#" align="left">Relev&acirc;ncia Ponto: </div></th>
                <td colspan="7" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left">Pontua&ccedil;&atilde;o<strong>:&nbsp; #auxpontua# &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</strong>Classifica&ccedil;&atilde;o<strong>: &nbsp;#auxclassif#</strong></div></td>
              </tr> 
              <cfif RIP_Resposta neq 'E'>
                <tr>
                  <td valign="top" bordercolor="999999" bgcolor="" scope="row" >&nbsp;</td>
				  <th valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left" >
                  <cfif RIP_Resposta neq 'N'>
                    Justificativa:
                    <cfelse>
                    N&atilde;o Conformidade:
                  </cfif>
				  </div></th>
                  <td colspan="7" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="justify">#Replace(RIP_Comentario,'IMAGENS_AVALIACOES/','../../../IMAGENS_AVALIACOES/','ALL')#</div></td>
                </tr>
                <cfif RIP_Resposta neq 'C' and RIP_Resposta neq 'V'>
                  <cfif '#trim(RIP_ReincInspecao)#' neq ''>
				     <cfset numReincInsp = Left(RIP_ReincInspecao,2) & '.' & Mid(RIP_ReincInspecao,3,4) & '/' & Right(RIP_ReincInspecao,4)>
                    <tr class="red_titulo">
                      <td valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</td>
                      <th valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left" class="style2">Reincid&ecirc;ncia:</div></th>
                      <td colspan="7" valign="top" bordercolor="999999" bgcolor="" scope="row"><span class="style2">#numReincInsp#&nbsp;-&nbsp;#RIP_ReincGrupo#.#RIP_ReincItem#</span></td>
                    </tr>
                  </cfif>
                  <cfset falta = #mid(LSCurrencyFormat(RIP_Falta, "local"), 4, 20)#>
                  <cfset sobra = #mid(LSCurrencyFormat(RIP_Sobra, "local"), 4, 20)#>
                  <cfset emrisco = #mid(LSCurrencyFormat(RIP_EmRisco, "local"), 4, 20)#>
                  <cfset total = '#RIP_Falta#' + '#RIP_Sobra#' + '#RIP_EmRisco#'>
                  <cfif '#total#' gt 0>
                    <tr>
                      <td valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</td>
                      <th valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left">Valores :</div></th>
                      <td colspan="7" valign="top" bordercolor="999999" bgcolor="" scope="row">Falta: #falta# &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Sobra: #sobra# &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Em Risco: #emrisco#</td>
                    </tr>
                  </cfif>
                </cfif>
                <cfif RIP_Resposta eq 'N'>
                  <cfset recom = Replace(RIP_Recomendacoes,"
                      ","<BR>" ,"All")>
                  <cfset recom = Replace(recom,"-----------------------------------------------------------------------------------------------------------------------","<BR>-----------------------------------------------------------------------------------------------------------------------<BR>" ,"All")>
                  <tr>
                    <td valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left" class="labelcell"></div></td>
                    <th valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left">Orienta&ccedil;&otilde;es:</div></th>
                    <td colspan="7" valign="top" bordercolor="999999" bgcolor="" scope="row">#recom#</td>
                  </tr>
                </cfif>
              </cfif>
              <tr>
                <cfif RIP_Resposta eq 'N'>
                  <cfset avaliacao = 'N&atilde;o Conforme'>
                  <cfelseif RIP_Resposta eq 'E'>
                  <cfset avaliacao = 'N&atilde;o Executa Tarefa'>
                  <cfelseif RIP_Resposta eq 'C'>
                  <cfset avaliacao = 'Conforme'>
                  <cfelseif RIP_Resposta eq 'V'>
                  <cfset avaliacao = 'N&atilde;o Verificado'>
                </cfif>
                <cfquery name="qSituacao" datasource="#dsn_inspecao#">
        SELECT Pos_Situacao_Resp, Pos_NCISEI, Pos_NCISEI, STO_Codigo, STO_Descricao, STO_Cor FROM ParecerUnidade INNER JOIN Situacao_Ponto ON STO_Codigo = Pos_Situacao_Resp WHERE Pos_Unidade ='#qryPapelTrabalho.RIP_Unidade#' and Pos_NumGrupo ='#qryPapelTrabalho.Grp_Codigo#' and Pos_NumItem='#qryPapelTrabalho.Itn_NumItem#' and Pos_Inspecao='#qryPapelTrabalho.INP_NumInspecao#'
                </cfquery>
                <td valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left" class="labelcell"></div></td>
                <th valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left">Avalia&ccedil;&atilde;o:</div></th>
                <cfset SEI = "#trim(qSituacao.Pos_NCISEI)#">
                <cfset SEI = "#left(SEI,5)#" & '.' & "#mid(SEI,6,6)#" & '/' & "#mid(SEI,12,4)#" & '-' & "#right(SEI,2)#">
                <td colspan="7" valign="top" bordercolor="999999" bgcolor="" scope="row"><strong <cfif #RIP_Resposta# eq 'N'>style="color:red"</cfif>>#avaliacao#
                      <cfif '#trim(qSituacao.Pos_NCISEI)#' neq ''>
                        <span style="color:red">com NCI - N° SEI: #SEI#</span>
                      </cfif>
                  </strong>
                    <cfquery name="qAvaliador" datasource="#dsn_inspecao#">
          SELECT Fun_Matric, Fun_Nome FROM Funcionarios WHERE Fun_Matric = '#RIP_MatricAvaliador#'
                    </cfquery>
                    <cfif #trim(RIP_MatricAvaliador)# neq ''>
						<cfset maskmatrusu = trim(qAvaliador.Fun_Matric)>
						<cfset maskmatrusu = left(maskmatrusu,1) & '.' &  mid(maskmatrusu,2,3) & '.***-' & right(maskmatrusu,1)> 
                        <span  style="margin-left:10px;color:black;font-size:12px">(Avaliado por: #maskmatrusu#-#trim(qAvaliador.Fun_Nome)#)</span>
                    </cfif>                </td>
              </tr>
              <cfif RIP_Resposta eq 'N' or '#TRIM(RIP_Recomendacao)#' neq ''>
                <tr class="noprint">
                  <td valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left" class="labelcell"></div></td>
                  <th valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left">Situa&ccedil;&atilde;o:</div></th>
                  <td colspan="2" ><cfif '#qSituacao.recordcount#' neq 0>
                      <cfif '#qSituacao.STO_Codigo#' neq 0 and '#qSituacao.STO_Codigo#' neq 11>
                        <div style="margin-bottom:10px">
                        <span class="noprint" style="background:###TRIM(qSituAcao.STO_Cor)#;padding:2px;color:##fff"> #TRIM(qSituacao.STO_Descricao)# </span>
                      </cfif>
                      <span class="noprint" style="background:###TRIM(qSituAcao.STO_Cor)#;padding:2px;color:##fff">
                      <cfif '#qSituacao.STO_Codigo#' eq 11>
                        <div style="margin-bottom:10px">
                        <span class="noprint" style="background:blue;padding:2px;color:##fff"> REVISADO </span>
                      </cfif>
                      </div>
                      </span>
                    </cfif>
                      <span class="noprint" style="background:###TRIM(qSituAcao.STO_Cor)#;padding:2px;color:##fff">
                      <cfif '#TRIM(RIP_Recomendacao)#' eq 'S'>
                        <div ><span style="font-family:arial;background:red;padding:2px;color:##fff">EM REAN&Aacute;LISE PELO INSPETOR</span></div>
                        <div class="noprint" align="center" style="margin-top:10px;float: left;"> <a style="cursor:pointer;"  onclick="capturaPosicaoScroll();abrirPopup('../../../itens_controle_revisliber_reanalise.cfm?cancelar=s&pg=pt&ninsp=#qryPapelTrabalho.INP_NumInspecao#&unid=#qryPapelTrabalho.RIP_Unidade#&ngrup=#qryPapelTrabalho.Grp_Codigo#&nitem=#qryPapelTrabalho.Itn_NumItem#&tpunid=#qryPapelTrabalho.TUN_Codigo#&modal=#qryPapelTrabalho.INP_Modalidade#',800,600)">
                          <div><img alt="Cancelar Rean&Aacute;LISE do item" src="../../../figuras/reavaliar.png" width="25"   border="0" /></div>
                          <div style="color:darkred;position:relative;font-size:12px">Cancelar Rean&aacute;lise</div>
                        </a> </div>
                      </cfif>
                      <cfif ('#qAcesso.Usu_GrupoAcesso#' eq 'gestores' or '#qAcesso.Usu_GrupoAcesso#' eq 'desenvolvedores')>
                        <cfif '#TRIM(RIP_Recomendacao)#' eq 'R'>
                          <div ><span class="noprint" style="font-family:arial;background:darkred;padding:2px;color:##fff">REANALISADO PELO INSPETOR</span></div>
                        </cfif>
                      </cfif>
                      <!--- Retirado do if abaixo para aparecer a palavra VALIDADO '#rsInspecaoNaoFinalizada.recordcount#' neq 0 and  --->
                      <cfif  (RIP_Resposta eq 'V' or (RIP_Resposta eq 'E' and '#Itn_ValidacaoObrigatoria#' eq 1)) and '#trim(RIP_Recomendacao)#' eq 'V' and  ('#rsVerifValidados.recordcount#' neq 0 or '#qInspecaoEmRevisao.recordcount#' neq 0)>
                        <div > <span class="noprint" style="font-family:arial;padding:4px;background:green;color:white">VALIDADO</span></div>
                      </cfif>
                    </span></td>
                </tr>
              </cfif>
              <cfif RIP_Resposta neq 'E'>
                <tr>
                  <td valign="top" bordercolor="999999" bgcolor=""></td>
                  <cfinvoke component="#vRelatorio#.GeraRelatorio.gerador.ctrl.controller"
                            method="geraAnexoNumero" returnvariable="qryAnexos">
                    <cfinvokeargument name="vNumInspecao" value="#qryPapelTrabalho.INP_NumInspecao#">
                    <cfinvokeargument name="vNumGrupo" value="#qryPapelTrabalho.Grp_Codigo#">
                    <cfinvokeargument name="vNumItem" value="#qryPapelTrabalho.Itn_NumItem#">
                  </cfinvoke>
                  <th bordercolor="999999" bgcolor=""><div align="left" id="anexo">Anexo:</div></th>
                  <td colspan="7" bordercolor="999999" bgcolor=""><div align="left" id="arquivo">
                      <cfloop query="qryAnexos">
                        <a target="_blank" href="../../../abrir_pdf_act.cfm?arquivo=#ListLast(qryAnexos.Ane_Caminho,'\')#"> <span class="link1">#ListLast(qryAnexos.Ane_Caminho,'\')#</span><br />
                        </a>
                      </cfloop>
                  </div></td>
                </tr>
              </cfif>
              <tr>
                <td valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left" class="labelcell"></div></td>
                <th valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left"></div></th>
                <td colspan="2"><!---                           <cfif '#rsSemNC.itemNC#' neq 0  and '#semNCvalidado#' is false and  '#TRIM(RIP_Recomendacao)#' neq 'S' and  ('#qAcesso.Usu_GrupoAcesso#' eq 'gestores' or '#qAcesso.Usu_GrupoAcesso#' eq 'desenvolvedores') and #trim(RIP_MatricAvaliador)# neq '' and structKeyExists(url,'pg') and '#url.pg#' eq 'controle'> 
                                  <div class="noprint" align="center" style="margin-top:10px;float: left;">
                                        <a style="cursor:pointer;"  onClick="capturaPosicaoScroll();abrirPopup('../../../itens_controle_revisliber_reanalise.cfm?pg=pt&ninsp=#qryPapelTrabalho.INP_NumInspecao#&unid=#qryPapelTrabalho.RIP_Unidade#&ngrup=#qryPapelTrabalho.Grp_Codigo#&nitem=#qryPapelTrabalho.Itn_NumItem#',700,380)">
                                        <div><img alt="Enviar p/ Reanálise do Inspetor ou Validar Reanálise" src="../../../figuras/reavaliar.png" width="25"   border="0" ></img></div>
                                        <div style="color:darkred;position:relative;font-size:12px"><cfif '#TRIM(RIP_Recomendacao)#' eq 'R'>Validar Reanálise<cfelse>Reanalisar</cfif></div></a>	
                                  </div>
      
                          </cfif>--->
                    <cfif ('#qSituacao.Pos_Situacao_Resp#' eq 0 or '#qSituacao.Pos_Situacao_Resp#' eq 11 or '#qSituacao.recordcount#' eq 0 or '#rsVerifValidados.recordcount#' neq 0 or '#rsSemNC.itemNC#' eq 0 or rsQuatEmRevisao.recordcount neq 0) and  '#TRIM(RIP_Recomendacao)#' neq 'S' and  ('#qAcesso.Usu_GrupoAcesso#' eq 'gestores' or '#qAcesso.Usu_GrupoAcesso#' eq 'desenvolvedores') and #trim(RIP_MatricAvaliador)# neq '' and structKeyExists(url,'pg') and '#url.pg#' eq 'controle'  >
                      <cfif '#rsInspecaoNaoFinalizada.recordcount#' neq 0 or '#rsVerifValidados.recordcount#' neq 0 or '#rsSemNC.itemNC#' eq 0 or rsQuatEmRevisao.recordcount neq 0>
                        <div class="noprint" align="center" style="margin-top:10px;float: left;"> <a style="cursor:pointer;"  onclick="capturaPosicaoScroll();abrirPopup('../../../itens_controle_revisliber_reanalise.cfm?pg=pt&ninsp=#qryPapelTrabalho.INP_NumInspecao#&unid=#qryPapelTrabalho.RIP_Unidade#&ngrup=#qryPapelTrabalho.Grp_Codigo#&nitem=#qryPapelTrabalho.Itn_NumItem#&tpunid=#qryPapelTrabalho.TUN_Codigo#&modal=#qryPapelTrabalho.INP_Modalidade#',800,600)">
                          <div><img alt="Enviar p/ Rean&Aacute;LISE do Inspetor ou Validar Rean&aacute;lise" src="../../../figuras/reavaliar.png" width="25"   border="0" /></div>
                          <div style="color:darkred;position:relative;font-size:12px">
                            <cfif '#TRIM(RIP_Recomendacao)#' eq 'R'>
                              Validar Rean&aacute;lise
                              <cfelse>
                              Reanalisar
                            </cfif>
                          </div>
                        </a> </div>
                        <cfif  (RIP_Resposta eq 'V' or (RIP_Resposta eq 'E' and '#Itn_ValidacaoObrigatoria#' eq 1)) and '#TRIM(RIP_Recomendacao)#' eq '' and '#rsSemNC.itemNC#' neq 0>
                          <cfif '#qSituacao.Pos_Situacao_Resp#' le 0 and '#rsQuatEmRevisao.quantEmRevisao#' le 0 and '#rsItemEmReanalise.recordcount#' le 0 and '#rsItemReanalisado.recordcount#' le 0 and '#rsVerifValidados.recordcount#' eq '1' >
                            <div class="noprint" align="center" style="margin-top:10px;margin-left:60px;float:left;"> <a style="cursor:pointer;"  onclick="if(confirm('Atenção! Após a validação, esta Avaliação será liberada e não será possível revisar outros itens.\n\nClique em OK se todos os itens CONFORME e NÃO EXECUTA já tiverem sido revisados, caso contrário, clique em Cancelar e realize a revisão dos itens.')){document.formPT.acao.value = 'validarItem';document.formPT.grupo.value = '#qryPapelTrabalho.Grp_Codigo#';document.formPT.item.value = '#qryPapelTrabalho.Itn_NumItem#';document.formPT.submit();}">
                              <div><img alt="Validar Avaliação" src="../../../figuras/checkVerde.png" width="25" border="0" /></div>
                              <div style="color:darkred;position:relative;font-size:12px">Validar</div>
                            </a> </div>
                            <cfelse>
                            <div class="noprint" align="center" style="margin-top:10px;margin-left:60px;float:left;"> <a style="cursor:pointer;"  onclick="if(confirm('Deseja validar a Avalia&ccedil;&atilde;o deste item?')){document.formPT.acao.value = 'validarItem';document.formPT.grupo.value = '#qryPapelTrabalho.Grp_Codigo#';document.formPT.item.value = '#qryPapelTrabalho.Itn_NumItem#';document.formPT.submit();}">
                              <div><img alt="Validar Avalia&ccedil;&atilde;o" src="../../../figuras/checkVerde.png" width="25" border="0" /></div>
                              <div style="color:darkred;position:relative;font-size:12px">Validar</div>
                            </a> </div>
                          </cfif>
                        </cfif>
                      </cfif>
                      <cfif ('#qSituacao.Pos_Situacao_Resp#' eq 0) and RIP_Resposta eq 'N' and  '#TRIM(RIP_Recomendacao)#' neq 'R'>
                        <div class="noprint" align="center" style="margin-top:10px;float: left;margin-left:60px" >
                          <cfif '#qSituacao.Pos_Situacao_Resp#' eq 0 and '#rsQuatEmRevisao.quantEmRevisao#' eq 1 and '#rsItemEmReanalise.recordcount#' eq 0 and '#rsItemReanalisado.recordcount#' eq 0 and '#rsVerifValidados.recordcount#' eq '0'>
                            <!---                                       <cfset M = M> --->
                            <a style="cursor:pointer;"  onclick="capturaPosicaoScroll();if(window.confirm('Aten&ccedil;&atilde;o! Após a revisão deste item, esta Avalia&ccedil;&atilde;o será liberada e não será possível revisar outros itens.\n\nClique em OK se todos os itens CONFORME e NÃO EXECUTA já tiverem sido revisados, caso contrário, clique em Cancelar e realize a revisão dos itens.')){
                                         window.open('../../../itens_controle_revisliber.cfm?pg=pt&Unid=#qryPapelTrabalho.RIP_Unidade#&Ninsp=#qryPapelTrabalho.INP_NumInspecao#&Ngrup=#qryPapelTrabalho.Grp_Codigo#&Nitem=#qryPapelTrabalho.Itn_NumItem#&situacao=#qSituAcao.Pos_Situacao_Resp#&vlrdec=#qryPapelTrabalho.Itn_ValorDeclarado#&modal=#qryPapelTrabalho.INP_Modalidade#','_self');}">
                            <cfelse>
                            </a>
                          </cfif>
                          <a style="cursor:pointer;"  onclick="capturaPosicaoScroll();if(window.confirm('Aten&ccedil;&atilde;o! Após a revisão deste item, esta Avalia&ccedil;&atilde;o será liberada e não será possível revisar outros itens.\n\nClique em OK se todos os itens CONFORME e NÃO EXECUTA já tiverem sido revisados, caso contrário, clique em Cancelar e realize a revisão dos itens.')){
                                         window.open('../../../itens_controle_revisliber.cfm?pg=pt&Unid=#qryPapelTrabalho.RIP_Unidade#&Ninsp=#qryPapelTrabalho.INP_NumInspecao#&Ngrup=#qryPapelTrabalho.Grp_Codigo#&Nitem=#qryPapelTrabalho.Itn_NumItem#&situacao=#qSituAcao.Pos_Situacao_Resp#&vlrdec=#qryPapelTrabalho.Itn_ValorDeclarado#&modal=#qryPapelTrabalho.INP_Modalidade#','_self');}"><a style="cursor:pointer;"  onclick="capturaPosicaoScroll();window.open('../../../itens_controle_revisliber.cfm?pg=pt&Unid=#qryPapelTrabalho.RIP_Unidade#&Ninsp=#qryPapelTrabalho.INP_NumInspecao#&Ngrup=#qryPapelTrabalho.Grp_Codigo#&Nitem=#qryPapelTrabalho.Itn_NumItem#&situacao=#qSituAcao.Pos_Situacao_Resp#&vlrdec=#qryPapelTrabalho.Itn_ValorDeclarado#&modal=#qryPapelTrabalho.INP_Modalidade#','_self')">
                          <div ><img  alt="Revisar" src="../../../figuras/revisar.png" width="25"   border="0" /></div>
                          <div style="color:darkred;position:relative;font-size:12px">Revisar</div>
                        </a> </a></div>
                      </cfif>
                    </cfif>                </td>
              </tr>
              <tr>
                <td valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left" class="labelcell"></div></td>
                <td colspan="8"  valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row" style="height:6px"></td>
              </tr>
            </cfoutput>
            <tr>
              <td colspan="10" valign="top" bordercolor="999999" bgcolor="" scope="row" >&nbsp;</td>
            </tr>
          </cfoutput>
          <tr>
            <td bordercolor="999999" bgcolor="" scope="row">&nbsp;</td>
            <th colspan="4" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left">Equipe:</div></th>
          </tr>
          <tr>
            <th valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</th>
            <th valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left"></div></th>
            <th colspan="3" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left"></div>
            Assinaturas:</th>
          </tr>
          <cfset mat = '#qryPapelTrabalho.INP_Coordenador#'>
          <tr>
            <th colspan="2" valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</th>
          </tr>
          <cfquery name="qInspetores" datasource="#dsn_inspecao#">
  SELECT Fun_Matric, Fun_Nome from Inspetor_Inspecao INNER JOIN Funcionarios ON Fun_Matric = IPT_MatricInspetor WHERE IPT_NumInspecao = '#qryPapelTrabalho.INP_NumInspecao#' ORDER BY Fun_Nome
          </cfquery>
          <cfoutput query= "qInspetores">
            <tr>
              <td valign="top" bordercolor="999999" bgcolor="">&nbsp;</td>
			  <!--- <cfset exibmatr = (Left(Fun_Matric,1) & '.' & Mid(Fun_Matric,2,3) & '.' & Mid(Fun_Matric,5,3) & '-' & Right(Fun_Matric,1)) & "   " & Fun_Nome> --->
			  <cfset exibmatr = (Left(Fun_Matric,1) & '.' & Mid(Fun_Matric,2,3) & '.***-' & Right(Fun_Matric,1)) & "   " & Fun_Nome>
			  <cfif '#mat#' eq '#Fun_Matric#'>
				<cfset exibmatr = exibmatr & "(COORDENADOR)">
			  </cfif>
			  
              <th colspan="4" valign="top" bordercolor="999999" bgcolor="">
			  <table width="100%" border="0">
                <tr>
                  <td width="51%">#exibmatr#</td>
                  <td width="49%">-------------------------------------------------------------------</td>
                </tr>
              </table>                   </th>
            </tr>
          </cfoutput>
          <tr>
            <th colspan="5" bordercolor="999999" bgcolor="">&nbsp;</th>
          </tr>
		   <tr>
            <th valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</th>
            <th colspan="4" valign="top" bordercolor="999999" bgcolor="" scope="row">
              <div align="center">
                <div align="right" style="position:relative;right:0px">
                  <table width="618" border="0" align="center">
                    <tr>
                      <td width="612"><div align="right">Data/Hora de Emiss&atilde;o: <cfoutput>#DateFormat(Now(),"DD/MM/YYYY")#</cfoutput> - <cfoutput>#TimeFormat(Now(),'HH:MM')#</cfoutput></div></td>
                    </tr>
                  </table>
                </div>
             </div></th>
          </tr>

          <cfif '#rsInspecaoNaoFinalizada.recordcount#' eq 0 and '#rsVerifValidados.recordcount#' eq 0 and '#qInspecaoEmRevisao.recordcount#' eq 0>
            <tr class="noprint">
              <th colspan="5" valign="top" bordercolor="999999" bgcolor="" scope="row"><button type="button" onClick=" window.print();">Imprimir</button></th>
            </tr>
          </cfif>
          <tr>
            <td colspan="5" valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</td>
          </tr>
    </table>
        <cfif ('#semNCvalidado#' is false) and ('#emReavaliacaoReavaliado#' eq 0) and ('#rsSemNC.itemNC#' eq 0)>
        <div align="center">
		<input name="submit" type="submit" type="button" class="botao" onClick="if(confirm('Deseja validar esta Avalia&ccedil;&atilde;o sem itens NÃO CONFORME?\n\nTodos os itens foram analisados?')){document.formPT.acao.value = 'validarSemNC';}" value="Validar Avalia&ccedil;&atilde;o sem Itens Não Conforme"></div>
      </cfif>
					
  </form>
</body>
</html>



