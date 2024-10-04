<cfoutput>
<cfprocessingdirective pageEncoding ="utf-8">
<cfsetting requesttimeout="15000">
<cfset rotina = 31>

<cfif rotina eq 31>	
<!--- envio por e-mail das conclusões de revisão no dia anterior --->
		<!--- Início - e-mail automático por unidade com NC --->
		<cfquery name="rsEnvio" datasource="#dsn_inspecao#">
			SELECT Usu_Email,INP_NumInspecao,INP_Unidade,INP_DTConcluirRevisao,Fun_Email,Rep_Email, Und_TipoUnidade, Und_Descricao, Und_Email, Und_CodReop, INP_DtInicInspecao,INP_Coordenador
			FROM (Inspecao INNER JOIN Unidades ON INP_Unidade = Und_Codigo) 
			INNER JOIN Usuarios ON INP_UserName = Usu_Login
			INNER JOIN Reops ON Und_CodReop = Rep_Codigo
			INNER JOIN Funcionarios ON INP_Coordenador = Fun_Matric
			WHERE INP_NumInspecao = '#numinsp#'
		</cfquery>
		<cfset startTime = CreateTime(0,0,0)> 
		<cfset endTime = CreateTime(0,0,45)> 
		<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
		</cfloop> 
			<cfset sdestina=''>
			<cfset emailrevisor = #rsEnvio.Usu_Email#>
			<cfset emailunid = #rsEnvio.Und_Email#>
			<cfset emailreopunid = #rsEnvio.Rep_Email#>
			<cfset emailcoord = #rsEnvio.Fun_Email#>
			<cfset emailcdd = "">
			<cfset emailreopcdd = "">

			<!--- adquirir o email do SCOI da SE --->
			<cfset scoi_se = left(rsEnvio.INP_Unidade,2)>
			<cfif scoi_se eq '03' or scoi_se eq '05' or scoi_se eq '65'>
				<cfset scoi_se = '10'>
			<cfelseif scoi_se eq '70'>
				<cfset scoi_se = '04'>						 					 				 
			</cfif>

			<cfquery name="rsSCOIEmail" datasource="#dsn_inspecao#">
				SELECT Ars_Email
				FROM Areas
				WHERE left(Ars_Codigo,2) = '#scoi_se#'  and (Ars_Descricao Like '%SEC AVAL CONT INTERNO/SGCIN%')
			</cfquery>
			<cfset startTime = CreateTime(0,0,0)> 
			<cfset endTime = CreateTime(0,0,15)> 
			<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
			</cfloop>
			<cfset emailscoi = #rsSCOIEmail.Ars_Email#>
			
			<cfset sdestina = "">
			<cfif emailrevisor neq "">
				<cfset sdestina = #sdestina# & ';' & #emailrevisor#>
			</cfif>
			
			<cfif emailunid neq "">
				<cfset sdestina = #sdestina# & ';' & #emailunid#>
			</cfif>

			<cfif emailreopunid neq "">
				<cfset sdestina = #sdestina# & ';' & #emailreopunid#>
			</cfif>

			<cfif emailcoord neq "">
				<cfset sdestina = #sdestina# & ';' & #emailcoord#>
			</cfif>

			<cfif emailscoi neq "">
				<cfset sdestina = #sdestina# & ';' & #emailscoi#>
			</cfif>		

			<cfset sdestina = #sdestina# & ';' & #qAcesso.Usu_Email#>		

			<cfif findoneof("@", trim(sdestina)) eq 0>
				<cfset sdestina = "gilvanm@correios.com.br">
			</cfif>
			<cfset sdestina = #sdestina# & ';teciogomes@correios.com.br;gilvanm@correios.com.br'> 
			<cfset assunto = 'Relatorio de Controle Interno - ' & #trim(rsEnvio.Und_Descricao)# & ' - Avaliação de Controle Interno ' & #rsEnvio.INP_NumInspecao#>
			<cfquery name="rsNC" datasource="#dsn_inspecao#">
				SELECT Pos_Inspecao
				FROM ParecerUnidade
				WHERE Pos_Inspecao='#rsEnvio.INP_NumInspecao#'
			</cfquery>
			<cfif rsNC.recordcount gt 0>			
				<cfif rsEnvio.Und_TipoUnidade neq 12 and rsEnvio.Und_TipoUnidade neq 16>  				
					<cfmail from="SNCI@correios.com.br" to="#sdestina#" subject="#assunto#" type="HTML">
						Mensagem automática. Não precisa responder!<br><br>
						<strong>
						Prezado(a) Gerente do(a) #trim(Ucase(rsEnvio.Und_Descricao))#, informamos que está disponível na intranet o Relatório de Controle Interno: Nº #rsEnvio.INP_NumInspecao#, realizada nessa Unidade na Data: #dateformat(rsEnvio.INP_DtInicInspecao,"dd/mm/yyyy")#. <br><br>

						&nbsp;&nbsp;&nbsp;Solicitamos acessá-lo para registro de sua resposta, conforme orientações a seguir:<br><br>

						&nbsp;&nbsp;&nbsp;a) Informar a Justificativa para ocorrência da falha: o que ocasionou o Problema (CAUSA); <br>

						&nbsp;&nbsp;&nbsp;b) Informar o Plano de Ações adotado para regularização da falha detectada, com prazo de implementação;<br>

						&nbsp;&nbsp;&nbsp;c) Anexar no sistema os Comprovantes de regularização da situação encontrada e/ou das Ações implementadas (em PDF).<br><br>

						&nbsp;&nbsp;&nbsp;Registrar a resposta no Sistema Nacional de Controle Interno - SNCI  num prazo de dez (10) dias úteis, contados a partir da data de entrega do Relatório. <br>
						&nbsp;&nbsp;&nbsp;O não cumprimento ensejará em perda de prazo.<br><br>

						&nbsp;&nbsp;&nbsp;Acesse o SNCI endereço: (http://intranetsistemaspe/snci/rotinas_inspecao.cfm) ou clique no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">Relatório de Controle Interno.</a><br><br>

						&nbsp;&nbsp;&nbsp;Atentar para as orientações deste e-mail para registro de sua manifestação no SNCI. Respostas incompletas serão devolvidas para complementação. <br><br>

						&nbsp;&nbsp;&nbsp;Em caso de dúvidas, entrar em contato com a Equipe de Controle Interno localizada na SE, por meio do endereço eletrônico:  #emailscoi#.<br><br>
						<table>
							<tr>
								<td><strong>Unidade : #rsEnvio.INP_Unidade# - #rsEnvio.Und_Descricao#</strong></td>
							</tr>
							<tr>
								<td><strong>Relatório: #rsEnvio.INP_NumInspecao#</strong></td>
							</tr>
							<tr>
								<td><strong>------------------------------------------</strong></td>
							</tr>
						</table>
						<br>
						&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
						</strong>
					</cfmail>
					<cfset posparecer = DateFormat(rsEnvio.INP_DTConcluirRevisao,"DD/MM/YYYY") & '>Conclusão da Revisão e Liberação da Avaliação' & CHR(13) & CHR(13)
					& 'Prezado(a) Gerente do(a)' & #trim(Ucase(rsEnvio.Und_Descricao))# & ', informamos que está disponível na intranet o Relatório de Controle Interno: Nº' & #rsEnvio.INP_NumInspecao# & ', realizada nessa Unidade na Data: ' & #dateformat(rsEnvio.INP_DtInicInspecao,"dd/mm/yyyy")# & CHR(13) & CHR(13) 
					& 'Solicitamos acessá-lo para registro de sua resposta, conforme orientações a seguir:' & CHR(13) & CHR(13) 
					& 'a) Informar a Justificativa para ocorrência da falha: o que ocasionou o Problema (CAUSA);' & CHR(13) 
					& 'b) Informar o Plano de Ações adotado para regularização da falha detectada, com prazo de implementação;' & CHR(13) 
					& 'c) Anexar no sistema os Comprovantes de regularização da situação encontrada e/ou das Ações implementadas (em PDF).' & CHR(13) & CHR(13) 
					& 'Registrar a resposta no Sistema Nacional de Controle Interno - SNCI num prazo de dez (10) dias úteis, contados a partir da data de entrega do Relatório.' & CHR(13) 
					& 'O não cumprimento ensejará em perda de prazo.' & CHR(13) & CHR(13) 
					& 'Acesse o SNCI endereço: (http://intranetsistemaspe/snci/rotinas_inspecao.cfm) ou clique no link: Relatório de Controle Interno.' & CHR(13) & CHR(13) 
					& 'Atentar para as orientações deste e-mail para registro de sua manifestação no SNCI. Respostas incompletas serão devolvidas para complementação.' & CHR(13) & CHR(13) 
					& 'Em caso de dúvidas, entrar em contato com a Equipe de Controle Interno localizada na SE, por meio do endereço eletrônico:' & CHR(13) & CHR(13) 
					& 'Unidade : ' & #rsEnvio.INP_Unidade# & '-' & #rsEnvio.Und_Descricao# & CHR(13) 
					& 'Relatório:' &  #rsEnvio.INP_NumInspecao# 
					& CHR(13) & CHR(13) & 'Desde já agradecemos a sua atenção.' 
					& CHR(13)
					& '-----------------------------------------------------------------------------------------------------------------------'>
				<cfelse>
					<cfmail from="SNCI@correios.com.br" to="#sdestina#" subject="#assunto#" type="HTML">
						Mensagem automática. Não precisa responder!<br><br>
						<strong>
						Prezado(a) Gerente do(a) #trim(Ucase(rsEnvio.Und_Descricao))#, informamos que está disponível na intranet o Relatório de Controle Interno: Nº #rsEnvio.INP_NumInspecao#, realizada nessa Unidade na Data: #dateformat(rsEnvio.INP_DtInicInspecao,"dd/mm/yyyy")#. <br><br>

						&nbsp;&nbsp;&nbsp;Solicitamos acessá-lo para registro de sua resposta, conforme orientações a seguir:<br><br>

						&nbsp;&nbsp;&nbsp;a) Informar a Justificativa para ocorrência da falha: o que ocasionou o Problema (CAUSA); <br>

						&nbsp;&nbsp;&nbsp;b) Informar o Plano de Ações adotado para regularização da falha detectada, com prazo de implementação;<br>

						&nbsp;&nbsp;&nbsp;c) Anexar no sistema os Comprovantes de regularização da situação encontrada e/ou das Ações implementadas (em PDF).<br><br>

						&nbsp;&nbsp;&nbsp;Registrar a resposta no Sistema Nacional de Controle Interno - SNCI  num prazo de dez (10) dias úteis, contados a partir da data de entrega do Relatório. <br>
						&nbsp;&nbsp;&nbsp;O não cumprimento ensejará em perda de prazo.<br><br>

						&nbsp;&nbsp;&nbsp;Acesse o SNCI endereço: (http://intranetsistemaspe/snci/rotinas_inspecao.cfm) ou clique no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">Relatório de Controle Interno.</a><br><br>

						&nbsp;&nbsp;&nbsp;Atentar para as orientações deste e-mail para registro de sua manifestação no SNCI. Respostas incompletas serão devolvidas para complementação, <br>
						&nbsp;&nbsp;&nbsp;desde que esteja dentro do prazo de 30 dias úteis a contar da entrega do Relatório. <br><br>   

						&nbsp;&nbsp;&nbsp;Após esse prazo, a situação será direcionada diretamente para área gestora do Contrato de Terceirizadas para adoção das ações previstas em contrato. <br><br>                      

						&nbsp;&nbsp;&nbsp;Em caso de dúvidas, entrar em contato com a Equipe de Controle Interno localizada na SE, por meio do endereço eletrônico:  #emailscoi#.<br><br>

						<table>
						<tr>
						<td><strong>Unidade : #rsEnvio.INP_Unidade# - #rsEnvio.Und_Descricao#</strong></td>
						</tr>
						<tr>
						<td><strong>Relatório: #rsEnvio.INP_NumInspecao#</strong></td>
						</tr>
						<tr>
						<td><strong>------------------------------------------</strong></td>
						</tr>
						</table>
						<br>
						&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
						</strong>
					</cfmail>
		
					<cfset posparecer = DateFormat(rsEnvio.INP_DTConcluirRevisao,"DD/MM/YYYY") & '>Conclusão da Revisão e Liberação da Avaliação' & CHR(13) & CHR(13)
					& 'Prezado(a) Gerente do(a)' & #trim(Ucase(rsEnvio.Und_Descricao))# & ', informamos que está disponível na intranet o Relatório de Controle Interno: Nº' & #rsEnvio.INP_NumInspecao# & ', realizada nessa Unidade na Data: ' & #dateformat(rsEnvio.INP_DtInicInspecao,"dd/mm/yyyy")# & CHR(13) & CHR(13) 
					& 'Solicitamos acessá-lo para registro de sua resposta, conforme orientações a seguir:' & CHR(13) & CHR(13) 
					& 'a) Informar a Justificativa para ocorrência da falha: o que ocasionou o Problema (CAUSA);' & CHR(13) 
					& 'b) Informar o Plano de Ações adotado para regularização da falha detectada, com prazo de implementação;' & CHR(13) 
					& 'c) Anexar no sistema os Comprovantes de regularização da situação encontrada e/ou das Ações implementadas (em PDF).' & CHR(13) & CHR(13) 
					& 'Registrar a resposta no Sistema Nacional de Controle Interno - SNCI num prazo de dez (10) dias úteis, contados a partir da data de entrega do Relatório.' & CHR(13) 
					& 'O não cumprimento ensejará em perda de prazo.' & CHR(13) & CHR(13) 
					& 'Acesse o SNCI endereço: (http://intranetsistemaspe/snci/rotinas_inspecao.cfm) ou clique no link: Relatório de Controle Interno.' & CHR(13) & CHR(13) 
					& 'Atentar para as orientações deste e-mail para registro de sua manifestação no SNCI. Respostas incompletas serão devolvidas para complementação.' & CHR(13) 
					& 'Desde que esteja dentro do prazo de 30 dias úteis a contar da entrega do Relatório.' & CHR(13) & CHR(13) 
					& 'Após esse prazo, a situação será direcionada diretamente para área gestora do Contrato de Terceirizadas para adoção das ações previstas em contrato.' & CHR(13) & CHR(13) 
					& 'Em caso de dúvidas, entrar em contato com a Equipe de Controle Interno localizada na SE, por meio do endereço eletrônico:' & CHR(13) & CHR(13) 
					& 'Unidade : ' & #rsEnvio.INP_Unidade# & '-' & #rsEnvio.Und_Descricao# & CHR(13) 
					& 'Relatório:' &  #rsEnvio.INP_NumInspecao# 
					& CHR(13) & CHR(13) & 'Desde já agradecemos a sua atenção.' 
					& CHR(13)
					& '-----------------------------------------------------------------------------------------------------------------------'>      
				</cfif>          
				<!--- Update na tabela parecer unidade --->
				<cfquery datasource="#dsn_inspecao#">
					UPDATE ParecerUnidade SET Pos_Parecer = '#posparecer#'
					WHERE Pos_Inspecao='#rsEnvio.INP_NumInspecao#' and Pos_Situacao_Resp = 14
				</cfquery>    		    
			<cfelse>	
					<!--- SEM NC --->
				<cfmail from="SNCI@correios.com.br" to="#sdestina#" subject="#assunto#" type="HTML">
					Mensagem automática. Não precisa responder!<br><br>
					<strong>
					Prezado(a) Gerente do(a) #trim(Ucase(rsEnvio.Und_Descricao))#<br><br>
					&nbsp;&nbsp;&nbsp;informamos que não houve Não Conformidades no Relatório de Controle Interno: Nº #rsEnvio.INP_NumInspecao#, realizada nessa Unidade na Data: #dateformat(rsEnvio.INP_DtInicInspecao,"dd/mm/yyyy")#. <br><br>
					&nbsp;&nbsp;&nbsp;Em caso de dúvidas, entrar em contato com a Equipe de Controle Interno localizada na SE, por meio do endereço eletrônico: #emailscoi#.<br><br>
					<br>
					&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
					</strong>
				</cfmail>     				
		</cfif>
</cfif>	
<br>
numinsp: #numinsp#<br>
</cfoutput>
Fim processamento!