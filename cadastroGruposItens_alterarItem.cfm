<cfprocessingdirective pageEncoding ="utf-8">
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	<cfinclude template="permissao_negada.htm">
	<cfabort>
</cfif>     
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_DR,Usu_GrupoAcesso, Usu_Matricula, Usu_Email, Usu_Apelido,Usu_Coordena from usuarios 
	where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<cfif isDefined("form.formAltItem") >
    <cfparam name="form.acao" default="#form.acao#">
    <cfparam name="form.selAltItemAno" default="#form.selAltItemAno#">
    <cfparam name="form.selAltItemGrupo" default="#form.selAltItemGrupo#">
    <cfparam name="form.selAltItem" default="#form.selAltItem#">
    <cfparam name="form.tipos" default="#form.tipos#">
    <cfparam name="form.selAltModalidade" default="#form.selAltModalidade#">
    <cfparam name="form.modalidades" default="#form.modalidades#">
    <cfparam name="form.selAltItemPontuacao" default="#form.selAltItemPontuacao#">
    <cfparam name="form.selAltItemPontuacaoAGF" default="#form.selAltItemPontuacaoAGF#">
    <cfparam name="form.frmptos" default="#form.frmptos#">
	<cfparam name="form.frmptosAGF" default="#form.frmptosAGF#">
<cfelse>
    <cfparam name="form.acao" default="">
    <cfparam name="form.selAltItemAno" default="">
    <cfparam name="form.selAltItemGrupo" default="">
    <cfparam name="form.selAltItem" default="">
    <cfparam name="form.tipos" default="">
    <cfparam name="form.selAltModalidade" default="">
    <cfparam name="form.modalidades" default="">
    <cfparam name="form.selAltItemPontuacao" default="">
    <cfparam name="form.selAltItemPontuacaoAGF" default="">
	<cfparam name="form.frmptos" default="">
	<cfparam name="form.frmptosAGF" default="">	
</cfif>
<cfquery name="rsPta" datasource="#dsn_inspecao#">
	SELECT PTC_Seq, PTC_Valor, PTC_Descricao, PTC_Status, PTC_dtultatu, PTC_Username, PTC_Franquia 
	FROM Pontuacao WHERE PTC_Ano = '#form.selAltItemAno#'
</cfquery> 
<cfif isDefined("form.acao") and "#form.acao#" eq 'altItem'>
		<cfif rsPta.recordcount lte 0>
			   <cfoutput>
				 <cflocation url="SNCI_MENSAGEM.cfm?form.motivo=BASE CADASTRAL: Falta informar os dados na tabela PONTUACAO para o ano: #form.selAltItemAno#">
			   </cfoutput>
		</cfif>
		<!---  --->
        <cfset tipoUnidadeEncontrado =''>
        <cfset tipoUnidadeNaoExcluir =''>
        <!---Se existirem tipos de unidade a serem exclu�dos do PLANO DE TESTE, verifica quais deles j� fizeram parte de alguma avalia��o--->
        <cfif "#form.tiposExcluidos#" neq ''>        
            <cfquery datasource="#dsn_inspecao#" name="rsChecklistUtilizado">
                SELECT  (rtrim(TUN_Descricao) + ':' + convert(varchar,count(RIP_NumInspecao))) + ' avalia&ccedil;&otilde;es' as totalAvaliacoes, TUN_Codigo FROM Resultado_Inspecao
                INNER JOIN Unidades ON Und_Codigo = RIP_Unidade
                INNER JOIN Inspecao ON INP_NumInspecao = RIP_NumInspecao
                INNER JOIN Tipo_Unidades ON TUN_Codigo = Und_TipoUnidade
                WHERE Und_TipoUnidade in(#form.tiposExcluidos#)  AND RIP_Ano = '#form.selAltItemAno#'
                AND RIP_NumGrupo = '#form.selAltItemGrupo#' AND RIP_NumItem = '#form.selAltItem#' AND INP_Modalidade = '#form.selAltModalidade#'
                GROUP BY TUN_Codigo,TUN_Descricao
            </cfquery> 
            
            <cfset tipoUnidadeEncontrado = ValueList(rsChecklistUtilizado.totalAvaliacoes,', ')> 
            <cfset tipoUnidadeNaoExcluir = ValueList(rsChecklistUtilizado.TUN_Codigo,',')> 
            
        </cfif>
        
        
        <cftransaction>
<!--- 				<script>
					<cfoutput>
					 alert('ID da pontua��oAC:' + '#form.frmptos#' + '     ID da pontua��OAGF:' + '#form.frmptosAGF#');
					</cfoutput>
				</script> 
				<cfset gil = gil>  --->
				
                <!---Altera a tabela TipoUnidade_ItemVerificacao com o valor da pontua��o para cada tipo de unidade e ano do item--->               
                <cfloop list="#form.tipos#" index="i">
                    <cfset tipo = "#i#">
					 <!--- Ajustes para os campos: Itn_Pontuacao, Itn_Classificacao e Itn_PTC_Seq --->
					 <!--- obter os valores para compor o campo: Itn_PTC_Seq --->
					 <cfif tipo neq 12>
						<cfset  auxini = 1>
						<cfset  auxfim = len(trim(#form.frmptos#))>
						<cfloop condition="auxini lt auxfim">
							<cfif auxini is 1>
							<cfset TUIPontuacaoDesc =  mid(form.frmptos,auxini,2)>
							<cfelse>
							<cfset TUIPontuacaoDesc = TUIPontuacaoDesc & ',' & mid(form.frmptos,auxini,2)>
							</cfif>
							<cfset  auxini = auxini + 2>
						</cfloop>
						<cfset auxptodesc = TUIPontuacaoDesc>
						<cfif right(auxptodesc,1)  eq ','>
						  <cfset auxptodesc = left(auxptodesc,len(auxptodesc) -1)>
						</cfif>
						<cfset auxpontua = form.selAltItemPontuacao>
					<cfelse>
							<cfset  auxini = 1>
							<cfset  auxfim = len(trim(#form.frmptos#))>
							<cfloop condition="auxini lt auxfim">
							   <cfif auxini is 1>
								 <cfset TUIPontuacaoDescAGF =  mid(form.frmptos,auxini,2)>
							   <cfelse>
								 <cfset TUIPontuacaoDescAGF = TUIPontuacaoDescAGF & ',' & mid(form.frmptos,auxini,2)>
							   </cfif>
							 <cfset  auxini = auxini + 2>
							</cfloop>					
							<!--- fim TUIPontuacaoDesc  --->
							 <cfset auxptodescAGF = TUIPontuacaoDescAGF & ',' & form.frmptosAGF> 
							<cfif right(auxptodescAGF,1)  eq ','>
							  <cfset auxptodescAGF = left(auxptodescAGF,len(auxptodescAGF) -1)>
							</cfif>							 
							<cfset auxpontua = form.selAltItemPontuacaoAGF>	
					</cfif>
					<!--- Obter a pontua��o max pelo ano e tipo da unidade --->
					<cfquery name="rsPtoMax" datasource="#dsn_inspecao#">
						SELECT TUP_PontuacaoMaxima 
						FROM Tipo_Unidade_Pontuacao 
						WHERE TUP_Ano = '#form.selAltItemAno#' AND TUP_Tun_Codigo in (#tipo#)
					</cfquery>
					<cfif rsPtoMax.recordcount lte 0>
					 <cflocation url="SNCI_MENSAGEM.cfm?form.motivo=BASE CADASTRAL: Falta informar os dados na tabela TIPO_UNIDADE_PONTUACAO para o ano: #form.selAltItemAno# e Cod_Tipo_Unidade = #tipo#">
					</cfif>					
					<!--- calcular o perc de classificacao do item --->	
					<cfset PercClassifItem = NumberFormat(((auxpontua / rsPtoMax.TUP_PontuacaoMaxima) * 100),999)>	
					<!--- calculo da descricao do item a saber GRAVE, MEDIANO ou LEVE --->
					<cfif PercClassifItem gt 40>
						<cfset ClassifITEM = 'GRAVE'> 
					<cfelseif PercClassifItem gt 10 and PercClassifItem lte 40>
						<cfset ClassifITEM = 'MEDIANO'> 
					<cfelseif PercClassifItem lte 10>
						<cfset ClassifITEM = 'LEVE'> 
					</cfif>		
					<!--- Fim Ajustes para os campos: Itn_Pontuacao, Itn_Classificacao e Itn_PTC_Seq --->		
					<!---Altera a tabela Itens_Verificacao--->
					<cfif tipo neq 12>
						<cfquery datasource="#dsn_inspecao#">
							UPDATE Itens_Verificacao SET Itn_Descricao ='#form.altItemDescricao#' , Itn_Orientacao = '#form.altItemOrientacao#'
														, Itn_Amostra = '#form.altItemAmostra#', Itn_Norma = '#form.altItemNorma#'
														, Itn_ValorDeclarado = '#form.selCadItemValorDec#'
														, Itn_DtUltAtu = CONVERT(DATETIME, getdate(), 103) , Itn_UserName = '#qAcesso.Usu_Matricula#'
														, Itn_ValidacaoObrigatoria = '#form.selAltValidObrig#' 
														, Itn_PreRelato = '#form.altItemPreRelato#' 
														, Itn_OrientacaoRelato = '#form.altItemOrientacaoRelato#'
														, Itn_Pontuacao = #form.selAltItemPontuacao#
														, Itn_PTC_Seq = '#auxptodesc#'
														, Itn_Classificacao = '#ClassifITEM#'
			
							WHERE Itn_Ano = '#form.selAltItemAno#' AND Itn_Modalidade = '#form.selAltModalidade#' AND Itn_TipoUnidade = #tipo# AND Itn_NumGrupo = '#form.selAltItemGrupo#' AND Itn_NumItem = '#form.selAltItem#' 
						</cfquery>		

						<cfquery datasource="#dsn_inspecao#">
							UPDATE TipoUnidade_ItemVerificacao SET TUI_Pontuacao = #form.selAltItemPontuacao#, TUI_Pontuacao_Seq = '#auxptodesc#', TUI_Classificacao = '#ClassifITEM#'
							WHERE TUI_TipoUnid = #tipo# AND TUI_Ano = '#form.selAltItemAno#' AND TUI_GrupoItem = '#form.selAltItemGrupo#' AND TUI_ItemVerif = #form.selAltItem# and TUI_Modalidade = '#form.selAltModalidade#'
						</cfquery>
				        <cfset RIPCaractvlr = 'NAO QUANTIFICADO'>
						<cfif listfind('#auxptodesc#','10')>
							<cfset RIPCaractvlr = 'QUANTIFICADO'>
						</cfif>					
						<cfquery datasource="#dsn_inspecao#">
							UPDATE Resultado_Inspecao SET RIP_Caractvlr = '#RIPCaractvlr#'
							WHERE RIP_Ano = #form.selAltItemAno# AND RIP_NumGrupo = #form.selAltItemGrupo# AND RIP_NumItem = #form.selAltItem#
						</cfquery> 
						
					<cfelse>
						<cfquery datasource="#dsn_inspecao#">
							UPDATE Itens_Verificacao SET Itn_Descricao ='#form.altItemDescricao#' , Itn_Orientacao = '#form.altItemOrientacao#'
														, Itn_Amostra = '#form.altItemAmostra#', Itn_Norma = '#form.altItemNorma#'
														, Itn_ValorDeclarado = '#form.selCadItemValorDec#'
														, Itn_DtUltAtu = CONVERT(DATETIME, getdate(), 103) , Itn_UserName = '#qAcesso.Usu_Matricula#'
														, Itn_ValidacaoObrigatoria = '#form.selAltValidObrig#' 
														, Itn_PreRelato = '#form.altItemPreRelato#' 
														, Itn_OrientacaoRelato = '#form.altItemOrientacaoRelato#'
														, Itn_Pontuacao = #form.selAltItemPontuacaoAGF#
														, Itn_PTC_Seq = '#auxptodescAGf#'
														, Itn_Classificacao = '#ClassifITEM#'
			
							WHERE Itn_Ano = '#form.selAltItemAno#' AND Itn_Modalidade = '#form.selAltModalidade#' AND Itn_TipoUnidade = #tipo# AND Itn_NumGrupo = '#form.selAltItemGrupo#' AND Itn_NumItem = '#form.selAltItem#' 
						</cfquery>		
					
						<cfquery datasource="#dsn_inspecao#">
							UPDATE TipoUnidade_ItemVerificacao SET TUI_Pontuacao = #form.selAltItemPontuacaoAGF#, TUI_Pontuacao_Seq = '#auxptodescAGF#', TUI_Classificacao = '#ClassifITEM#'
							WHERE TUI_TipoUnid = #tipo# AND TUI_Ano = '#form.selAltItemAno#' AND TUI_GrupoItem = '#form.selAltItemGrupo#' AND TUI_ItemVerif = #form.selAltItem# and TUI_Modalidade = '#form.selAltModalidade#'
						</cfquery>	
				        <cfset RIPCaractvlr = 'NAO QUANTIFICADO'>
						<cfif listfind('#auxptodescAGF#','10')>
							<cfset RIPCaractvlr = 'QUANTIFICADO'>
						</cfif>	
											
						<cfquery datasource="#dsn_inspecao#">
							UPDATE Resultado_Inspecao SET RIP_Caractvlr = '#RIPCaractvlr#'
							WHERE RIP_Ano = #form.selAltItemAno# AND RIP_NumGrupo = #form.selAltItemGrupo# AND RIP_NumItem = #form.selAltItem#
						</cfquery>	 								
					</cfif>		
					<!---  --->
         </cfloop>
                
					<!---Se existirem tipos de unidade a serem exclu�dos do PLANO DE TESTE--->
					<cfif "#form.tiposExcluidos#" neq ''> 
						<cfquery datasource="#dsn_inspecao#" >
							DELETE FROM Itens_Verificacao 
							 WHERE Itn_Ano = '#form.selAltItemAno#' AND Itn_Modalidade = '#form.selAltModalidade#' AND Itn_NumGrupo = #form.selAltItemGrupo# 
									AND Itn_NumItem = #form.selAltItem# 
								<cfif "#form.tiposExcluidos#" neq ''>
									AND Itn_TipoUnidade in(#form.tiposExcluidos#)
								</cfif>
								<cfif "#tipoUnidadeNaoExcluir#" neq ''>
									AND Itn_TipoUnidade not in(#tipoUnidadeNaoExcluir#)
								</cfif>
						</cfquery>
						<cfquery datasource="#dsn_inspecao#" >
							DELETE FROM TipoUnidade_ItemVerificacao 
							 WHERE TUI_Ano = '#form.selAltItemAno#' AND TUI_GrupoItem = #form.selAltItemGrupo# 
									AND TUI_ItemVerif = #form.selAltItem# AND TUI_Modalidade = '#form.selAltModalidade#'
								<cfif "#form.tiposExcluidos#" neq ''>
									AND TUI_TipoUnid in(#form.tiposExcluidos#)
								</cfif>
								<cfif "#tipoUnidadeNaoExcluir#" neq ''>
									AND TUI_TipoUnid not in(#tipoUnidadeNaoExcluir#)
								</cfif>
						</cfquery>
					</cfif>
                	<!---Se existirem tipos de unidade a serem inclu�dos do PLANO DE TESTE--->
                	<cfif "#form.tiposIncluidos#" neq ''>
                    	<cfloop list="#form.tiposIncluidos#" index="i">
							<cfset tipo = "#i#">
							 <!--- Ajustes para os campos: Itn_Pontuacao, Itn_Classificacao e Itn_PTC_Seq --->
							 <!--- obter os valores para compor o campo: Itn_PTC_Seq --->
							<cfif tipo neq 12>
								<cfset  auxini = 1>
								<cfset  auxfim = len(trim(#form.frmptos#))>
								<cfloop condition="auxini lt auxfim">
									<cfif auxini is 1>
									<cfset TUIPontuacaoDesc =  mid(form.frmptos,auxini,2)>
									<cfelse>
									<cfset TUIPontuacaoDesc = TUIPontuacaoDesc & ',' & mid(form.frmptos,auxini,2)>
									</cfif>
									<cfset  auxini = auxini + 2>
								</cfloop>
								<cfset auxptodesc = TUIPontuacaoDesc>
								<cfset auxpontua = form.selAltItemPontuacao>
							<cfelse>
									<cfset  auxini = 1>
									<cfset  auxfim = len(trim(#form.frmptos#))>
									<cfloop condition="auxini lt auxfim">
									   <cfif auxini is 1>
										 <cfset TUIPontuacaoDescAGF =  mid(form.frmptos,auxini,2)>
									   <cfelse>
										 <cfset TUIPontuacaoDescAGF = TUIPontuacaoDescAGF & ',' & mid(form.frmptosAGF,auxini,2)>
									   </cfif>
									 <cfset  auxini = auxini + 2>
									</cfloop>					
									<!--- fim TUIPontuacaoDesc  --->
									
									<cfset TUIPontuacaoDescAGF = TUIPontuacaoDescAGF & ',' & form.frmptosAGF>  
								<!--- 	<cfset auxptodescAGF = TUIPontuacaoDescAGF> --->
									<cfset auxpontuaAGF = form.selAltItemPontuacaoAGF>	
							</cfif>
							<!--- Obter a pontuacao max pelo ano e tipo da unidade --->
							<cfquery name="rsPtoMax" datasource="#dsn_inspecao#">
								SELECT TUP_PontuacaoMaxima 
								FROM Tipo_Unidade_Pontuacao 
								WHERE TUP_Ano = '#form.selAltItemAno#' AND TUP_Tun_Codigo in (#tipo#)
							</cfquery>
							<!--- calcular o perc de classificacao do item --->	
							<cfset PercClassifItem = NumberFormat(((auxpontua / rsPtoMax.TUP_PontuacaoMaxima) * 100),999)>	
							<!--- calculo da descricao do item a saber GRAVE, MEDIANO ou LEVE --->
							<cfif PercClassifItem gt 40>
								<cfset ClassifITEM = 'GRAVE'> 
							<cfelseif PercClassifItem gt 10 and PercClassifItem lte 40>
								<cfset ClassifITEM = 'MEDIANO'> 
							<cfelseif PercClassifItem lte 10>
								<cfset ClassifITEM = 'LEVE'> 
							</cfif>	 				
							<!--- Fim Ajustes para os campos: Itn_Pontuacao, Itn_Classificacao e Itn_PTC_Seq --->								
					<cfif tipo neq 12>
							<cfquery datasource="#dsn_inspecao#">
									INSERT INTO Itens_Verificacao(Itn_Modalidade,Itn_NumGrupo,Itn_NumItem,Itn_Descricao,Itn_Orientacao,Itn_Situacao,Itn_DtUltAtu,Itn_UserName,Itn_ValorDeclarado,Itn_TipoUnidade,Itn_Ano,Itn_Amostra,Itn_Norma,Itn_ValidacaoObrigatoria,Itn_PreRelato,Itn_OrientacaoRelato, Itn_Pontuacao, Itn_PTC_Seq, Itn_Classificacao)
									VALUES('#form.selAltModalidade#', #form.selAltItemGrupo#, #form.selAltItem#, '#form.altItemDescricao#','#form.altItemOrientacao#'
												, 'D', CONVERT(DATETIME, getdate(), 103), '#qAcesso.Usu_Matricula#', '#form.selCadItemValorDec#', #tipo#, '#form.selAltItemAno#'
												,'#form.altItemAmostra#','#form.altItemNorma#','#form.selAltValidObrig#','#form.altItemPreRelato#','#form.altItemOrientacaoRelato#',#form.selAltItemPontuacao#, '#auxptodesc#', '#ClassifITEM#')                                    
							</cfquery>						
						
							<cfquery datasource="#dsn_inspecao#">
								INSERT INTO TipoUnidade_ItemVerificacao (TUI_Modalidade,TUI_TipoUnid,TUI_GrupoItem,TUI_ItemVerif,TUI_DtUltAtu,TUI_UserName,TUI_Ano,TUI_Ativo)
								VALUES('#form.selAltModalidade#',#tipo#,#form.selAltItemGrupo#,#form.selAltItem#,CONVERT(DATETIME, getdate(), 103),'#qAcesso.Usu_Matricula#',#form.selAltItemAno#,0) 
							</cfquery>
							<!---Altera ao campo TUI_Pontuacao tabela TipoUnidade_ItemVerificacao para cada tipo de unidade e ano do item--->
							
								<cfquery datasource="#dsn_inspecao#">
									UPDATE TipoUnidade_ItemVerificacao SET TUI_Pontuacao = #form.selAltItemPontuacao#,TUI_Pontuacao_Seq='#auxptodesc#',TUI_Classificacao='#ClassifITEM#'
									WHERE TUI_Modalidade='#form.selAltModalidade#' and TUI_TipoUnid = #tipo# AND TUI_Ano = '#form.selAltItemAno#' AND TUI_GrupoItem = '#form.selAltItemGrupo#' AND TUI_ItemVerif = '#form.selAltItem#'
								</cfquery> 
								<cfset RIPCaractvlr = 'NAO QUANTIFICADO'>
								<cfif listfind('#auxptodesc#','10')>
									<cfset RIPCaractvlr = 'QUANTIFICADO'>
								</cfif>
													
								<cfquery datasource="#dsn_inspecao#">
									UPDATE Resultado_Inspecao SET RIP_Caractvlr = '#RIPCaractvlr#'
									WHERE RIP_Ano = #form.selAltItemAno# AND RIP_NumGrupo = #form.selAltItemGrupo# AND RIP_NumItem = #form.selAltItem#
								</cfquery>	 							
							<cfelse>
								<cfquery datasource="#dsn_inspecao#">
										INSERT INTO Itens_Verificacao(Itn_Modalidade,Itn_NumGrupo,Itn_NumItem,Itn_Descricao,Itn_Orientacao,Itn_Situacao,Itn_DtUltAtu,Itn_UserName,Itn_ValorDeclarado,Itn_TipoUnidade,Itn_Ano,Itn_Amostra,Itn_Norma,Itn_ValidacaoObrigatoria,Itn_PreRelato,Itn_OrientacaoRelato, Itn_Pontuacao, Itn_PTC_Seq, Itn_Classificacao)
										VALUES('#form.selAltModalidade#', #form.selAltItemGrupo#, #form.selAltItem#, '#form.altItemDescricao#','#form.altItemOrientacao#'
													, 'D', CONVERT(DATETIME, getdate(), 103), '#qAcesso.Usu_Matricula#', '#form.selCadItemValorDec#', #tipo#, '#form.selAltItemAno#'
													,'#form.altItemAmostra#','#form.altItemNorma#','#form.selAltValidObrig#','#form.altItemPreRelato#','#form.altItemOrientacaoRelato#',#form.selAltItemPontuacaoAGF#, '#auxptodescAGF#', '#ClassifITEM#')                                    
								</cfquery>							
								<cfquery datasource="#dsn_inspecao#">
									INSERT INTO TipoUnidade_ItemVerificacao (TUI_Modalidade,TUI_TipoUnid,TUI_GrupoItem,TUI_ItemVerif,TUI_DtUltAtu,TUI_UserName,TUI_Ano,TUI_Ativo)
									VALUES('#form.selAltModalidade#',#tipo#,#form.selAltItemGrupo#,#form.selAltItem#,CONVERT(DATETIME, getdate(), 103),'#qAcesso.Usu_Matricula#',#form.selAltItemAno#,0) 
								</cfquery>							
								<cfquery datasource="#dsn_inspecao#">
									UPDATE TipoUnidade_ItemVerificacao SET TUI_Pontuacao = #form.selAltItemPontuacaoAGF#,TUI_Pontuacao_Seq='#auxptodescAGF#',TUI_Classificacao='#ClassifITEM#'
									WHERE TUI_Modalidade='#form.selAltModalidade#' and TUI_TipoUnid = #tipo# AND TUI_Ano = '#form.selAltItemAno#' AND TUI_GrupoItem = '#form.selAltItemGrupo#' AND TUI_ItemVerif = '#form.selAltItem#'
								</cfquery> 
								<cfset RIPCaractvlr = 'NAO QUANTIFICADO'>
								<cfif listfind('#auxptodescAGF#','10')>
									<cfset RIPCaractvlr = 'QUANTIFICADO'>
								</cfif>
											
								<cfquery datasource="#dsn_inspecao#">
									UPDATE Resultado_Inspecao SET RIP_Caractvlr = '#RIPCaractvlr#'
									WHERE RIP_Ano = #form.selAltItemAno# AND RIP_NumGrupo = #form.selAltItemGrupo# AND RIP_NumItem = #form.selAltItem#
								</cfquery>									
							</cfif>
                    </cfloop>
                </cfif>
        </cftransaction>

        <script type="text/javascript"> 
            <cfoutput>var tipoUnidadeEncontrado = '#tipoUnidadeEncontrado#';</cfoutput>
            if(tipoUnidadeEncontrado == ''){
                alert('Item alterado com sucesso!');
                var frm = document.getElementById('formAltItem');
            }else{
                alert('Existem avalições cadastradas no SNCI para o item selecionado e tipo(s) de unidade desmarcado(s) no PLANO DE TESTE:\n\n' + tipoUnidadeEncontrado + '\n\nEsta alteração não foi realizada.');
                alert('Demais alterações realizadas com sucesso!');
            }                
        </script>
</cfif>

<cfif isDefined("form.acao") and "#form.acao#" eq 'excItem'>
<!---   				    <script>
				   <cfoutput>
					 alert('tipos:' + '#form.tipos#' + '  tiposincluidos' + '#form.tiposIncluidos#' + '  Tipos Excluidos : ' + '#form.tiposExcluidos#' + '  ano : ' + '#form.selAltItemAno#');
				   </cfoutput>
				   </script>  
<cfset gil = gil> --->
    <cftransaction>
        <cfquery datasource="#dsn_inspecao#" >
            DELETE FROM TipoUnidade_ItemVerificacao 
            WHERE TUI_Ano = '#form.selAltItemAno#' and TUI_GrupoItem = #form.selAltItemGrupo# 
                and TUI_ItemVerif =#form.selAltItem#  
        </cfquery> 

         <cfquery datasource="#dsn_inspecao#" >
            DELETE FROM Itens_Verificacao 
            WHERE Itn_Ano = '#form.selAltItemAno#' and Itn_NumGrupo = #form.selAltItemGrupo#
                  AND Itn_NumItem = #form.selAltItem#
        </cfquery> 
    </cftransaction>
    <script type="text/javascript">           
        alert('Item excluído com sucesso!');
        window.open('cadastroGruposItens.cfm','_self');           
    </script
></cfif>

<cfset anoInic = year(Now())> 							
<cfset anoFinal = anoInic + 1>
                                            
<cfquery datasource="#dsn_inspecao#" name="rsAnoFiltro">
    SELECT DISTINCT Itn_Ano FROM Itens_Verificacao 
    WHERE Itn_Ano BETWEEN #anoInic# AND #anoFinal#
    ORDER BY Itn_Ano
</cfquery>

<cfif isDefined("form.selAltItemAno") and '#form.selAltItemAno#' neq ''>
    <cfquery datasource="#dsn_inspecao#" name="rsGrupoFiltro">
        SELECT * FROM Grupos_Verificacao WHERE Grp_Ano = '#form.selAltItemAno#'
    </cfquery>
</cfif>

<cfif isDefined("form.selAltItemGrupo") and '#form.selAltItemGrupo#' neq ''>
     <cfquery datasource="#dsn_inspecao#" name="rsItemFiltro">
        SELECT DISTINCT Itn_NumItem, Itn_Descricao FROM Itens_Verificacao 
        WHERE Itn_Ano = '#form.selAltItemAno#' AND Itn_NumGrupo = '#form.selAltItemGrupo#' 
    </cfquery>
</cfif>

<cfif isDefined("form.selAltItem") and '#form.selAltItem#' neq ''>
    <cfquery datasource="#dsn_inspecao#" name="rsChecklist">
        SELECT * FROM Itens_Verificacao 
        INNER JOIN TipoUnidade_ItemVerificacao ON TUI_GrupoItem = Itn_NumGrupo AND TUI_ItemVerif = Itn_NumItem AND TUI_Ano = Itn_Ano
        WHERE TUI_Ano = '#form.selAltItemAno#' AND Itn_NumGrupo = #form.selAltItemGrupo# AND Itn_NumItem = #form.selAltItem# 
    </cfquery>
    <cfquery dbtype="query" name="rsModFiltro">
        SELECT DISTINCT TUI_Modalidade FROM rsChecklist
    </cfquery>
</cfif>

<cfif isDefined("form.selAltModalidade") and '#form.selAltModalidade#' neq ''>
    <!--- Verifica se o item selecionado j� faz parte de alguma avalia��o para impedir exclus�o--->
    <cfquery datasource="#dsn_inspecao#" name="rsChecklistJaUtilizado">
                SELECT  RIP_NumInspecao FROM Resultado_Inspecao
                INNER JOIN Unidades ON Und_Codigo = RIP_Unidade
                INNER JOIN Inspecao ON INP_NumInspecao = RIP_NumInspecao
                WHERE RIP_Ano = '#form.selAltItemAno#' AND RIP_NumGrupo = '#form.selAltItemGrupo#' 
                      AND RIP_NumItem = '#form.selAltItem#' AND INP_Modalidade = '#form.selAltModalidade#'
    </cfquery>
    <!--- Fim da verifica se o item seleciona j� faz parte de alguma avalia��o para impedir exclus�o--->


    <cfquery dbtype="query" name="rsItemFiltrado">
        SELECT * FROM rsChecklist 
        WHERE TUI_Modalidade = '#form.selAltModalidade#'
    </cfquery>

    <cfquery dbtype="query" name="rsTiposFiltrado">
        SELECT DISTINCT TUI_TipoUnid FROM rsItemFiltrado
    </cfquery>

    <cfset tipos = ValueList(rsTiposFiltrado.TUI_TipoUnid)>

</cfif>


<!--- <cfquery name="qTipoUnidades" datasource="#dsn_inspecao#">
    SELECT * FROM Tipo_Unidades
	ORDER BY TUN_Descricao
</cfquery> --->
<cfquery name="qTipoUnidades" datasource="#dsn_inspecao#">
SELECT *
FROM Tipo_Unidades INNER JOIN Tipo_Unidade_Pontuacao ON TUN_Codigo = TUP_Tun_Codigo
WHERE TUP_Ano = '#form.selAltItemAno#' order by TUN_Descricao
</cfquery>


<html xmlns="http://www.w3.org/1999/xhtml">

    <head>
        <title>SNCI - CADASTRO DE GRUPOS E ITENS</title>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">


    <style type="text/css">    
        .tituloDivAltItem{
            padding:5px;
            position:relative;
            top: -19px;
            background: #003366;
            border: 1px solid #fff;
        }
    </style>

    <script type="text/javascript"> 

        //muda a cor dos tipos e modalidades selecionados
        function mudaCorCheckedAlt(b){
            (b.checked==true) ? b.parentNode.style.background='green' : b.parentNode.style.background='none';
            (b.checked==true) ? b.parentNode.style.border='1px solid #fff' : b.parentNode.style.border='1px solid transparent';
        }

         //muda a cor dos tipos Alterados
        function mudaCorCheckedTipo(b){
            <cfoutput>
                <cfif isDefined("form.selAltItem") and '#form.selAltItem#' neq ''>
                    var tipo = '#tipos#';
                </cfif>
            </cfoutput>

            if(tipo.indexOf(b.value) == -1){//se nao estiver na lista tipo
                if(b.checked==false){//se nao estiver marcado
                    b.parentNode.style.background='none';
                    b.parentNode.style.border='1px solid transparent';
                }else{//se estiver marcado
                    b.parentNode.style.background='blue';
                    b.parentNode.style.border='1px solid #fff'
                }      
            }else{//se estiver na lista tipo
                 if(b.checked==false){//se nao estiver marcado
                    b.parentNode.style.background='red';
                    b.parentNode.style.border='1px solid #fff'         
                 }else{//se estiver marcado
                    b.parentNode.style.background='green';
                    b.parentNode.style.border='1px solid #fff'    
                 }
               
            }         
        }

        function selectChecbox(nomeChecbox){
            var checkboxes = document.getElementsByName(nomeChecbox);  
            var numberOfCheckedItems = 0; 
            for(var i = 0; i < checkboxes.length; i++){
                if(checkboxes[i].checked){ 
				   selecptos(checkboxes[i].id);
				   selecptosAGF(checkboxes[i].id);
                   numberOfCheckedItems++;  
                   if(numberOfCheckedItems > 1){
                     selecionados = selecionados + "," + checkboxes[i].value;
                   }
                   if(numberOfCheckedItems == 1){
                     selecionados = checkboxes[i].value;
                   }
                }  
            }
            if(numberOfCheckedItems == 0){
              selecionados ='';  
            }
            return selecionados;
        }


        var tiposSelecionados = '';
        var modalidadesSelecionadas = '';
        

        function valida_formAltItem(){
            tiposSelecionados = selectChecbox("selAltItemTipoUnidade");

            var frm = document.getElementById('formAltItem');

            if (frm.altItemDescricao.value == '') {
				alert('Informe uma descrição para item.');
				frm.altItemDescricao.focus();
				return false;
			}


            if (CKEDITOR.instances.altItemOrientacao.getData()== '') {
				alert('Informe "COMO EXERCUTAR/PROCEDIMENTOS ADOTADOS" para o item.');
				CKEDITOR.instances.altItemOrientacao.focus();
				return false;
			}

            if (CKEDITOR.instances.altItemOrientacao.getData()== '') {
				alert('Informe "COMO EXERCUTAR/PROCEDIMENTOS ADOTADOS" para o item.');
				CKEDITOR.instances.altItemOrientacao.focus();
				return false;
			}

            if (CKEDITOR.instances.altItemAmostra.getData()== '') {
				alert('Informe a Amostra para o item.');
				CKEDITOR.instances.altItemAmostra.focus();
				return false;
			}

            if (CKEDITOR.instances.altItemNorma.getData()== '') {
				alert('Informe a Norma para o item.');
				CKEDITOR.instances.altItemNorma.focus();
				return false;
			}

            if (CKEDITOR.instances.altItemPreRelato.getData()== '') {
				alert('Informe um modelo de relato para o item.');
				CKEDITOR.instances.altItemPreRelato.focus();
				return false;
			}
            
            if (CKEDITOR.instances.altItemOrientacaoRelato.getData()== '') {
				alert('Informe uma orientação para o órgão.');
				CKEDITOR.instances.altItemOrientacaoRelato.focus();
				return false;
			}

            if (tiposSelecionados == '') {
				alert('Selecione, pelo menos, 01(um) tipo de unidade para a qual o item será aplicado.');
				return false;
			}

            if ((frm.selAltItemPontuacao.value == '' ||  frm.selAltItemPontuacao.value == 0) && isVisible(document.getElementById('selAltItemPontuacao'))==true) {
				alert('Informe a Pontuação para o item.\n\nObs.: Utilize a "Calculadora de Pontuação".');
                frm.selAltItemPontuacao.focus();
				return false;
			}  

            if (frm.frmptos.value == '' || frm.frmptos.value == 0)  {
				alert('Revisar e Confirmar a Pontuação para o item.\n\nObs.: Utilize a "Calculadora de Pontuação".');
                frm.selAltItemPontuacao.focus();
				return false;
			//mostraCalculadora();
			} 			

            if ((frm.selAltItemPontuacaoAGF.value == '' || frm.selAltItemPontuacaoAGF.value == 0) && isVisible(document.getElementById('selAltItemPontuacaoAGF'))==true) {
				alert('Informe a Pontuação do item para AGF.\n\nObs.: Utilize a "Calculadora de Pontuação".');
                frm.selAltItemPontuacaoAGF.focus();
				return false;
			}

            function inArray(array, elem){
                var len = array.length;
                for(var i = 0 ; i < len;i++){
                    if(array[i] == elem){return i;}
                }
                return -1;
            } 

            if(window.confirm('Deseja alterar este Item?')){  
                frm.tipos.value=tiposSelecionados;

                <cfoutput>
                    var tiposCadastrados = '#tipos#';
                    var tiposCadastrados = tiposCadastrados.split(',');
                    tiposSelecionados = tiposSelecionados.split(',');
                </cfoutput>
                var tiposExcluidos ='';  
                var tiposIncluidos ='';   
                for(var i = 0; i < tiposCadastrados.length; i++){
                   if(inArray(tiposSelecionados, tiposCadastrados[i])==-1 ){
                       if(tiposExcluidos != ''){
                            tiposExcluidos=tiposCadastrados[i] + ","+ tiposExcluidos;     
                       }else{
                            tiposExcluidos=tiposCadastrados[i];  
                       }
                        
                   }
                }
                for(var i = 0; i < tiposSelecionados.length; i++){
                   if(inArray(tiposCadastrados, tiposSelecionados[i])==-1 ){
                       if(tiposIncluidos != ''){
                            tiposIncluidos=tiposSelecionados[i] + ","+ tiposIncluidos;     
                       }else{
                            tiposIncluidos=tiposSelecionados[i];  
                       }
                        
                   }
                }
          
                frm.acao.value = 'altItem';
                frm.tiposExcluidos.value = tiposExcluidos;
                frm.tiposIncluidos.value = tiposIncluidos;
			    aguarde();
                setTimeout('document.getElementById("formAltItem").submit();',2000);
                return true;	
            }else{
                return false;
            }

        }  

        function valida_formExcItem(){
            var frm = document.getElementById('formAltItem');
            var quantUtil = 0;
            <cfoutput>
                <cfif isDefined("form.selAltModalidade") and '#form.selAltModalidade#' neq ''>
                   quantUtil = '#rsChecklistJaUtilizado.recordcount#';
                </cfif>
            </cfoutput>
           
            if(quantUtil !=0){
                alert('Foram localizados registros de avaliação para o Item.\n\n A exclusão não poderá ser realizada!')
                return false;
            }
           
            if(quantUtil == 0){

                if(window.confirm('Confirma a exclusão definitiva do item?\n\nAtenção: O item será excluído do Plano de Teste de todas as modalidades de Avaliação!')){
                    frm.acao.value = 'excItem';
                    aguarde();
                    setTimeout('document.getElementById("formAltItem").submit();',2000);
                    return true;
                }else{
                    return false;
                }
            }


        }

        

        //script para calculadora de pontua��o

        // apos load muda cor dos tipos de unidades conforme item selecionado
        window.onload = function(){
            
         
            temAGF();
            if(document.forms['formAltItem']){
                var all = document.forms['formAltItem'].elements;
                for(x=0;x<all.length;x++){
                    mudaCorCheckedAlt(all[x]);
                } 
                
            }
        };
        function temAGF(){
            
            tiposSelecionados = selectChecbox("selAltItemTipoUnidade"); 
            tiposSelecionadosList = tiposSelecionados.split(',')
  
            if(tiposSelecionados.indexOf("12") != -1 && tiposSelecionadosList.length >=1){
                document.getElementById('checkPontuacaoAGFdiv').style.visibility = 'visible';
                document.getElementById('checkPontuacaoAGFdiv').style.display = 'block';
                document.getElementById('totalDiv').style.visibility = 'visible';
                document.getElementById('totalDiv').style.position = 'relative';
                document.getElementById('totalAGFdiv').style.visibility = 'visible';
                document.getElementById('selAltItemPontuacaoDiv').style.position = 'relative'; 
                document.getElementById('selAltItemPontuacaoAGFdiv').style.visibility = 'visible'; 
                document.getElementById('selAltItemPontuacaoDiv').style.visibility = 'visible';
                document.getElementById('selAltItemPontuacaoDiv').style.position = 'relative';
                
            }
            
            if(tiposSelecionados.indexOf("12") != -1 && tiposSelecionadosList.length==1){
                document.getElementById('checkPontuacaoAGFdiv').style.visibility = 'visible';
                document.getElementById('checkPontuacaoAGFdiv').style.display = 'block';                
                document.getElementById('totalAGFdiv').style.visibility = 'visible';
                document.getElementById('totalDiv').style.visibility = 'hidden';
                document.getElementById('totalDiv').style.position = 'absolute';
                if(document.getElementById('selAltItemPontuacaoAGFdiv')){
                  document.getElementById('selAltItemPontuacaoAGFdiv').style.visibility = 'visible'; 
                }
                if(document.getElementById('selAltItemPontuacaoDiv')){
                    document.getElementById('selAltItemPontuacaoDiv').style.visibility = 'hidden';
                    document.getElementById('selAltItemPontuacaoDiv').style.position = 'absolute';
                }

            }
            
            if(tiposSelecionados.indexOf("12") == -1){
                document.getElementById('checkPontuacaoAGFdiv').style.visibility = 'hidden';
                document.getElementById('checkPontuacaoAGFdiv').style.display = 'none';  
                document.getElementById('totalAGFdiv').style.visibility = 'hidden';
                document.getElementById('totalDiv').style.visibility = 'visible';
                document.getElementById('totalDiv').style.position = 'relative';
                if(document.getElementById('selAltItemPontuacaoAGFdiv')){
                    document.getElementById('selAltItemPontuacaoAGFdiv').style.visibility = 'hidden';
                }
               
                if(document.getElementById('selAltItemPontuacaoDiv')){
                    document.getElementById('selAltItemPontuacaoDiv').style.visibility = 'visible'; 
                    document.getElementById('selAltItemPontuacaoDiv').style.position = 'relative'; 
                }    
                            
            }
        }

        var isVisible = function(el){
                // returns true iff el and all its ancestors are visible
                return el.style.display !== 'none' && el.style.visibility !== 'hidden'
                && (el.parentElement? isVisible(el.parentElement): true)
            };


        function SomenteNumero(e){
            var tecla=(window.event)?event.keyCode:e.which;   
            if((tecla>47 && tecla<58)) return true;
            else{
                if (tecla==8 || tecla==0) return true;
            else  return false;
            }
        }
      var ptTotal=0;        
        function calcularPontuacao(){
  		    document.getElementById('selAltItemPontuacao').value = 0;
			document.getElementById('frmptos').value = '';
			document.getElementById('frmptosAGF').value = '';
			
            ptTotal = 0;      
			ptTotalAGF = 0;  
            var pontosSelecionados = selectChecbox("checkPontuacao");
            pontosSelecionados = pontosSelecionados.split(',');           
            for(var i = 0; i < pontosSelecionados.length; i++){
                ptTotal= ptTotal + (1*pontosSelecionados[i]);     
            }                     
            document.getElementById('pontuacaoCalculada').value = ptTotal;  
			
			var pntSelecagf = selectChecbox("checkPontuacaoAGF");
            pntSelecagf = pntSelecagf.split(',');           
		
            for(var i = 0; i < pntSelecagf.length; i++){
			   ptTotalAGF = ptTotalAGF + (1*pntSelecagf[i]);     
            } 
			document.getElementById('pontuacaoCalculadaAGF').value = ptTotal + (ptTotalAGF); 
			document.getElementById('selAltItemPontuacaoAGF').value = ptTotalAGF;
        }

        function inserePontuacao(){
            if (document.getElementById('pontuacaoCalculadaAGF').value == 0 && isVisible(document.getElementById('checkPontuacaoAGF'))==true) {
				alert('Selecione a pontuação adicional para a AGF.');
                document.getElementById('checkPontuacaoAGF').focus();
				return false;
			}else{           
                document.getElementById('selAltItemPontuacao').value = ptTotal; 
                document.getElementById('selAltItemPontuacaoAGF').value = ptTotal + (document.getElementById('selAltItemPontuacaoAGF').value *1); 
                document.getElementById("calculadoraPontuacaoAlt").style.visibility = 'hidden';
                document.getElementById("calculadoraPontuacaoAlt").style.display = 'none';
            }
        }		

        function mostraCalculadora(){
            if (isVisible(document.getElementById('calculadoraPontuacaoAlt'))==true) {
                document.getElementById("calculadoraPontuacaoAlt").style.visibility = 'hidden';
                document.getElementById("calculadoraPontuacaoAlt").style.display = 'none';
            }else{
                document.getElementById("calculadoraPontuacaoAlt").style.visibility = 'visible';
                document.getElementById("calculadoraPontuacaoAlt").style.display = 'block';
                document.getElementById("calculadoraPontuacaoAlt").focus();
            }
            
        }

        function fechaCalculadora(){
            document.getElementById("calculadoraPontuacaoAlt").style.visibility = 'hidden';
            document.getElementById("calculadoraPontuacaoAlt").style.display = 'none';
            
        }
        //Fim script para calculadora de pontua��o

        function mostraAvisoAlteracao(){
            if (isVisible(document.getElementById('avisoAlteracao'))==true) {
                document.getElementById("avisoAlteracao").style.visibility = 'hidden';
                document.getElementById("avisoAlteracao").style.display = 'none';
            }else{
                document.getElementById("avisoAlteracao").style.visibility = 'visible';
                document.getElementById("avisoAlteracao").style.display = 'block';
                document.getElementById("avisoAlteracao").focus();
            }
            
        }

        function getPosicaoElemento(elemID){
            var offsetTrail = document.getElementById(elemID);
            var offsetLeft = 0;
            var offsetTop = 0;
            while (offsetTrail) {
                offsetLeft += offsetTrail.offsetLeft;
                offsetTop += offsetTrail.offsetTop;
                offsetTrail = offsetTrail.offsetParent;
            }
            if (navigator.userAgent.indexOf("Mac") != -1 && 
                typeof document.body.leftMargin != "undefined") {
                offsetLeft += document.body.leftMargin;
                offsetTop += document.body.topMargin;
            }
            return {left:offsetLeft, top:offsetTop};
        }

        function PosicaoElemento(elemento, alvo){
            var top = getPosicaoElemento(elemento.id).top - 284 + 'px';
            var left = getPosicaoElemento(elemento.id).left + 67 + 'px';
            document.getElementById(alvo).style.top=top;
            document.getElementById(alvo).style.left=left;
        }

        function AbrirPopup(url,w,h) {
            var newW = w + 100;
            var newH = h + 100;
            var left = (screen.width-newW)/2;
            var top = (screen.height-newH)/2;

            var newwindow = window.open(url, 'name', 'width='+newW+',height='+newH+',left='+left+',top='+top+ ',toolbar=no,location=no, directories=no, status=no, menubar=no,scrollbars=yes, copyhistory=no');
            newwindow.resizeTo(newW, newH);
            //posiciona o popup no centro da tela
            newwindow.moveTo(left, top);
            newwindow.focus();
            return false;
        }
//=============================
function selecptos(a){
//	alert(a);
    var frm = document.getElementById('formAltItem');
	var aux = frm.frmptos.value;
	if (a < 16) {
    	frm.frmptos.value = aux + a;
	}
	//frm.frmptos.value = aux + a;
//	alert(aux);
 //  alert('frmptos: ' + frm.frmptos.value);
}
//=============================
function selecptosAGF(a){
	//alert(a);
    var frm = document.getElementById('formAltItem');
	if (a > 15) {
    	frm.frmptosAGF.value = a;
	}
//	alert(aux);
//    alert('valor salvo: ' + frm.frmptosAGF.value);
}

</script>

 
</head>
    <body id="main_body" style="background:#fff;" >

        <div align="left" >
            <form id="formAltItem" nome="formAltItem" enctype="multipart/form-data" method="post" >
                <input type="hidden" value="" id="acao" name="acao">
                <input type="hidden" value="" id="tipos" name="tipos"> 
                <input type="hidden" value="" id="tiposExcluidos" name="tiposExcluidos">
                <input type="hidden" value="" id="tiposIncluidos" name="tiposIncluidos">
				<input type="hidden" value="" id="frmptos" name="frmptos">
				<input type="hidden" value="" id="frmptosAGF" name="frmptosAGF">

                    <div align="left" style="padding:10px;border:1px solid #fff;width:835px;">
                        <div align="left">
								<span class="tituloDivAltItem" >Filtro</span>
						</div>
                        <div align="left" style="">
                            <div style="margin-bottom:10px;float:left;margin-right:20px;">
                                        <label  for="selAltItemAno" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">ANO:</label>
                                        <div ></div>	
                                        <select name="selAltItemAno" id="selAltItemAno" onChange="if(this.value!=''){aguarde(); setTimeout('javascript:formAltItem.submit();',2000)}else{window.open('cadastroGruposItens.cfm','_self')}" class="form" style="display:inline-block;background:#c5d4ea">										
                                            
                                            <option selected="selected" value=""></option>
                                            <cfoutput query="rsAnoFiltro">
                                                <option  <cfif "#Itn_Ano#" eq "#form.selAltItemAno#">selected</cfif> value="#Itn_Ano#">#Itn_Ano#</option>
                                            </cfoutput>
                                        </select>		
                            </div>        
                                    
                            <div style="margin-right:20px;margin-bottom:10px;float:left;">
                                <label  for="selAltItemGrupo" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">
                                GRUPO:</label>
                                <div ></div>	
                                        <select name="selAltItemGrupo" id="selAltItemGrupo"  onchange="if(this.value!=''){aguarde(); setTimeout('javascript:formAltItem.submit();',2000)}else{window.open('cadastroGruposItens.cfm','_self')}" class="form" style="display:inline-block;width:290px;background:#c5d4ea">										
                                        
                                            <option selected="selected" value=""></option>
                                            <cfif isDefined("form.selAltItemAno") and '#form.selAltItemAno#' neq ''>  
                                                <cfoutput query="rsGrupoFiltro">
                                                    <option  <cfif "#Grp_Codigo#" eq "#form.selAltItemGrupo#">selected</cfif> value="#Grp_Codigo#">#Grp_Codigo# - #Grp_Descricao#</option>
                                                </cfoutput>
                                            </cfif>
                                        </select>              		
                            </div> 

                            <div style="margin-right:20px;margin-bottom:10px;float:left;">
                                <label  for="selAltItem" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">
                                ITEM:</label>
                                <div ></div>	
                                <select name="selAltItem" id="selAltItem"  onchange="if(this.value!=''){aguarde(); setTimeout('javascript:formAltItem.submit();',2000)}else{window.open('cadastroGruposItens.cfm','_self')}" class="form" style="display:inline-block;width:290px;background:#c5d4ea">										
                                    <option selected="selected" value=""></option>
                                    <cfif isDefined("form.selAltItemGrupo") and '#form.selAltItemGrupo#' neq ''>  
                                        <cfoutput query="rsItemFiltro">
                                            <option  <cfif "#Itn_NumItem#" eq "#form.selAltItem#">selected</cfif> value="#Itn_NumItem#">#Itn_NumItem# - #Itn_Descricao#</option>
                                        </cfoutput>
                                    </cfif>
                                </select>              		
                            </div> 
                            <div style="margin-bottom:10px;float:left;">
                                <label  for="selAltModalidade" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">
                                MODALIDADE:</label>
                                <br>	
                                <select name="selAltModalidade" id="selAltModalidade"  class="form" onChange="aguarde(); setTimeout('javascript:formAltItem.submit();',2000)" style="display:inline-block;background:#c5d4ea">
                                    <option selected="selected" value=""></option>
                                    <cfif isDefined("form.selAltItem") and '#form.selAltItem#' neq ''>
                                        <cfoutput query="rsModFiltro">
                                            <option <cfif '#form.selAltModalidade#' eq  '#TUI_Modalidade#' >selected</cfif> value="#TUI_Modalidade#"><cfif "#TUI_Modalidade#" eq 0>PRESENCIAL<cfelseif "#TUI_Modalidade#" eq 1>A DIST&Acirc;NCIA<cfelse></cfif></option>
                                        </cfoutput>    
                                    </cfif>
                                </select>
						    </div>

                           
                        </div> 
                    </div>

                    <cfif isDefined("form.selAltModalidade") and '#form.selAltModalidade#' neq '' and '#rsModFiltro.recordcount#' neq 0> 
                        <!---   <div align="right" style="position:relative;top:20px;left:633px;width:200px;padding:10px"> 
                            <cfif '#rsItemFiltrado.TUI_Ativo#' eq 0>
                                <span  STYLE="background:darkred;color:#fff;padding:5px;border:1px solid #fff">ITEM DESATIVADO</span>
                            <cfelse>
                                <span   STYLE="background:blue;color:#fff;padding:5px;border:1px solid #fff">ITEM ATIVO</span></div>
                            </cfif>
                        </div>--->
                        <div align="left" style="padding:10px;border:1px solid #fff;width:835px;margin-top:20px">
                        
                            <div align="left">
                                <span class="tituloDivAltItem" >Informa&ccedil;&otilde;es dispon&iacute;veis para altera&ccedil;&atilde;o</span>
                            </div> 
                            <div style="margin-bottom:20px;">
                                <label  for="altItemDescricao" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                                DESCRI&Ccedil;&Atilde;O DO ITEM:</label>	
                                <div ></div>	
                                <textarea  name="altItemDescricao"  id="altItemDescricao" cols="112" rows="2" wrap="VIRTUAL" class="form" 
                                style="background:#fff;font-family:Verdana, Arial, Helvetica, sans-serif"><cfoutput>#rsItemFiltrado.Itn_Descricao#</cfoutput></textarea>		
                            </div>

                            <div style="margin-bottom:10px;float:left;">
                                <label  for="selAltItemValorDec" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">VALOR<br>DECLARADO:</label>
                                <div ></div>	
                                <select name="selCadItemValorDec" id="selCadItemValorDec"  class="form" style="display:inline-block;width:50px;">
                                    <option <cfif '#rsItemFiltrado.Itn_ValorDeclarado#' eq 'N'>selected</cfif> value="N">Não</option>
                                    <option <cfif '#rsItemFiltrado.Itn_ValorDeclarado#' eq 'S'>selected</cfif> value="S">Sim</option>
                                </select>			 										
                            </div>

                            <div style="margin-bottom:10px;margin-left:100px;width:200px;float:left;" title="Impede a visualização e tratamento do item em todas as páginas.">
                                <label  for="selAltVisualizacao" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">VISUALIZA&Ccedil;&Atilde;O<br>BLOQUEADA (TRATAMENTO):</label>
                                <div ></div>	
                                <select name="selAltVisualizacao" id="selAltVisualizacao"  class="form" style="display:inline-block;width:50px;">
                                    <option <cfif '#rsItemFiltrado.Itn_TipoUnidade#' eq ''>selected</cfif> value="">N&atilde;o</option>
                                    <option <cfif '#rsItemFiltrado.Itn_TipoUnidade#' eq '99'>selected</cfif> value="99">Sim</option>
                                </select>			 										
                            </div>

                            <div style="margin-bottom:10px;margin-left:200px;" title="Obriga que o gestor valide este item em caso de avaliação NãO EXECUTA.">
                                <label  for="selAltValidObrig"  style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">VALIDA&Ccedil;&Atilde;O<br>OBRIGAT&Oacute;RIA (N&Atilde;O EXECUTA):</label>
                                <div ></div>	
                                <select name="selAltValidObrig" id="selAltValidObrig"  class="form" style="display:inline-block;width:50px;">
                                    <option <cfif '#rsItemFiltrado.Itn_ValidacaoObrigatoria#' eq '0'>selected</cfif> value="0">N&atilde;o</option>
                                    <option <cfif '#rsItemFiltrado.Itn_ValidacaoObrigatoria#' eq '1'>selected</cfif> value="1">Sim</option>
                                </select>			 										
                            </div>

                            

                            <div align="left" style="margin-bottom:30px;">
<!---                             <div align="right" style="position:relative;top:53px;right:10px;z-index:2000">
                                <img src="Figuras/uploadpictures.png" onclick="AbrirPopup('formUploadImagem.cfm',600,400);" alt="Clique para enviar imagens ao servidor do SNCI." border="0" style="cursor:pointer;width:20px;"/>
                            </div> --->
                                <label  for="altItemOrientacao" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">COMO EXERCUTAR/PROCEDIMENTOS ADOTADOS:</label>	 
                                <div ></div>
                                <textarea  name="altItemOrientacao" id="altItemOrientacao" 
                                style="display:none!important;background:#fff;font-family:Verdana, Arial, Helvetica, sans-serif"><cfoutput>#rsItemFiltrado.Itn_Orientacao#</cfoutput></textarea>		
                            </div>

                            <div align="left" style="margin-bottom:30px;float:left;margin-right:7px">
                                <label  for="altItemAmostra" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">AMOSTRA:</label>	 
                                <div ></div>
                                <textarea  name="altItemAmostra" id="altItemAmostra" 
                                style="display:none!important;background:#fff;font-family:Verdana, Arial, Helvetica, sans-serif"><cfoutput>#rsItemFiltrado.Itn_Amostra#</cfoutput></textarea>		
                            </div>

                            <div align="left" style="margin-bottom:30px;">
                                <label  for="altItemNorma" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">NORMA:</label>	 
                                <div ></div>
                                <textarea  name="altItemNorma" id="altItemNorma" 
                                style="display:none!important;background:#fff;font-family:Verdana, Arial, Helvetica, sans-serif"><cfoutput>#rsItemFiltrado.Itn_Norma#</cfoutput></textarea>		
                            </div>

                            <div align="left" style="margin-bottom:30px;">
                                <label  for="altItemPreRelato" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">RELATO MODELO:</label>	 
                                <div ></div>
                                <textarea  name="altItemPreRelato" id="altItemPreRelato" 
                                style="display:none!important;background:#fff;font-family:Verdana, Arial, Helvetica, sans-serif"><cfoutput>#rsItemFiltrado.Itn_PreRelato#</cfoutput></textarea>		
                            </div>

                            <div align="left" style="margin-bottom:30px;">
                                <label  for="altItemOrientacaoRelato" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">ORIENTAÇÕES UNIDADE/ÓRGÃO:</label>	 
                                <div ></div>
                                <textarea  name="altItemOrientacaoRelato" id="altItemOrientacaoRelato" 
                                style="display:none!important;background:#fff;font-family:Verdana, Arial, Helvetica, sans-serif"><cfoutput>#rsItemFiltrado.Itn_OrientacaoRelato#</cfoutput></textarea>		
                            </div>



                            <div align="left" style="padding:10px;border:1px solid #fff;width:813px;margin-bottom:30px;">
                                <div align="left">
                                        <span class="tituloDivAltItem" style="font-size:12px">Plano de Teste</span>
                                </div>
                                <div style="margin-bottom:30px;" >
                                    <label  for="selAltItemTipoUnidade"  style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">
                                    TIPO DE UNIDADE: <span style="color:yellow">(tipos de unidade que tem este item em seu PLANO DE TESTE)</span></label> 
                                    <div ></div>
                                        <cfoutput query="qTipoUnidades">
                                            <div style="float:left;margin-right:15px;border:1px solid transparent;font-size:12px">
                                                <input type="checkbox"  name="selAltItemTipoUnidade" 
                                                <cfif listFind(tipos,'#TUN_Codigo#') neq 0>checked</cfif>
                                                value="#TUN_Codigo#"  onclick="mudaCorCheckedTipo(this);temAGF()"><a style="color:##fff;padding:1px;">#TUN_Descricao#</a></input>  
                                            </div>
                                        </cfoutput>
                                </div>

                                <div style="margin-bottom:30px;border-bottom:1px solid #fff;padding-bottom:20px">
                                    <label  style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size:8px;">
                                    Legenda:</label>                   	
                                    <a  style="background:green;font-size:8px;padding:2px;border:1px solid #fff">CADASTRADO</a>
                                    <a  style="background:blue;font-size:8px;padding:2px;border:1px solid #fff">SER&Aacute; INCLU&Iacute;DO</a>
                                    <a  style="background:red;font-size:8px;padding:2px;border:1px solid #fff">SER&Aacute; EXCLU&Iacute;DO</a>
                                </div>  

                               <!---  <cfquery dbtype="query" name="rsItemFiltradoOutros">
                                    SELECT DISTINCT itn_Pontuacao, Itn_PTC_Seq FROM rsItemFiltrado WHERE TUI_TipoUnid<>12
                                </cfquery> --->
								 <cfquery dbtype="query" name="rsItemFiltradoOutros">
                                    SELECT DISTINCT itn_Pontuacao, Itn_PTC_Seq FROM rsItemFiltrado
                                </cfquery>
                               <!---  <cfquery dbtype="query" name="rsItemFiltradoAGF">
                                        SELECT DISTINCT itn_Pontuacao, Itn_PTC_Seq FROM rsItemFiltrado WHERE TUI_TipoUnid=12
                                </cfquery> --->

                                <div></div>
                                <div style="text-align:center;">
                                    <div align="left" style="float:left;margin-right:20px;">
                                        <button id="btCalculadoraAlt" onClick="mostraCalculadora();PosicaoElemento(this,'calculadoraPontuacaoAlt');" onmouseOver="this.style.backgroundColor='cornflowerBlue';" onMouseOut="this.style.backgroundColor='blue';"
                                        class="botaoCad" style="background-color:blue;color:#fff;font-size:10px;width:66px;padding:2px;">
                                        <span><img src="figuras/calculadora.png" width="30"  border="0"  ></img></span><div></div>Calculadora<br>Pontua&ccedil;&atilde;o</button>                     
                                    </div>

                                    <div id="selAltItemPontuacaoDiv" align="left" style="float:left;margin-right:20px;visibility:hidden;">
                                        <label  for="selAltItemPontuacao"  style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">
                                        PONTUA&Ccedil;&Atilde;O:</label> 
                                        <div></div>
                                        <input readonly type="text" id="selAltItemPontuacao" name="selAltItemPontuacao" size="3" onkeypress='return SomenteNumero(event)' style="position:relative;top:2px;text-align:center" 
                                        value="<cfoutput>#rsItemFiltradoOutros.itn_Pontuacao#</cfoutput>"></input> 
                                    </div>
                                
                                    <div id="selAltItemPontuacaoAGFdiv" align="left" style="visibility:hidden;">
                                        <label  for="selAltItemPontuacaoAGF"  style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">
                                        PONTUA&Ccedil;&Atilde;O AGF:</label> 
                                        <div></div>
                                        <input readonly type="text" id="selAltItemPontuacaoAGF" name="selAltItemPontuacaoAGF" size="3" onkeypress='return SomenteNumero(event)' style="position:relative;top:2px;text-align:center" 
                                        value="<cfoutput>#rsItemFiltradoOutros.itn_Pontuacao#</cfoutput>"></input>
                                    </div>   
                                </div> 


                            </div>
      

                        </div> 

                        <div align="center" style="margin-top:30px;">
                                <a type="button" onClick="return valida_formAltItem()" href="#" class="botaoCad" style="background:blue;color:#fff;font-size:12px;">
                                    Alterar</a> 
                                <a type="button" onClick="return valida_formExcItem()" href="#" class="botaoCad" style="margin-left:150px;background:red;color:#fff;font-size:12px;">
                                    Excluir este Item</a> 
                                <a type="button" onClick="javascript:if(confirm('Deseja cancelar as alterções realizadas?\n\nObs.: Esta ação não cancela as alterações já confirmadas.\n\nCaso afirmativo, clique em OK.')){window.open('cadastroGruposItens.cfm','_self')}" href="#" class="botaoCad" style="margin-left:150px;background:red;color:#fff;font-size:12px;">
                                    Cancelar</a>
                        </div>   
                <!---     </cfif> --->
               
                    <!---Calculadora de Pontua��o--->
                    <div id="calculadoraPontuacaoAlt" align="left" style="visibility:hidden;display:none;z-index:1000;background-color:#003390;position:absolute;padding:10px;border:3px solid lightGray;width:620px;">
                        <div align="left" style="padding:3px">   
                            <span class="tituloDivAltItem" style="font-size:12px;border:2px solid lightGray;align:center;top: -24px;background-color:#003390;">
                            <img src="figuras/calculadora.png" width="20"  border="0" style="position:relative;top:2px" ></img>                                   
                            Calculadora de Pontua&ccedil;&atilde;o</span>
                        </div>

                        <div style="border:1px solid transparent;font-size:12px">
						   <cfoutput query="rsPta">
								<cfif rsPta.PTC_Franquia is 'N'>
									 <cfset checar = ''>
									 <cfif listFind('#rsItemFiltradoOutros.Itn_PTC_Seq#','#rsPta.PTC_Seq#') neq 0>
									 	<cfset checar = 'checked'>
									 </cfif>
									<input type="checkbox" id="#rsPta.PTC_Seq#" name="checkPontuacao" value="#rsPta.PTC_Valor#" onClick="calcularPontuacao();" #checar#>#rsPta.PTC_Descricao# = <strong>#rsPta.PTC_Valor# pontos</strong></input>									 
									 <div></div> 
								 </cfif>
							</cfoutput>
							 <input type="hidden" name="teste1">
							  
<!---						
							<input type="checkbox"  name="checkPontuacao" value="9" onclick="calcularPontuacao();">TEM IMPACTO FINANCEIRO DIRETO = <strong>9 pontos</strong></input>
                            <div></div>
                            <input type="checkbox"  name="checkPontuacao" value="4" onclick="calcularPontuacao();">PODE ENSEJAR INDENIZA��O/PENALIZA��O � ECT/MULTAS CONTRATUAIS OU LEGAIS = <strong>4 pontos</strong></input>
                            <div></div>
                            <input type="checkbox"  name="checkPontuacao" value="2" onclick="calcularPontuacao();">DESCUMPRIMENTO DE LEI/NORMA EXTERNA = <strong>2 pontos</strong></input>
                            <div></div>
                            <input type="checkbox"  name="checkPontuacao" value="1" onclick="calcularPontuacao();">DESCUMPRIMENTO DE NORMA INTERNA = <strong>1 ponto</strong></input>
                            <div></div>
                            <input type="checkbox"  name="checkPontuacao" value="3" onclick="calcularPontuacao();">RISCO � SEGURAN�A E INTEGRIDADE DO PATRIM�NIO, BENS, OBJETOS E PESSOAS = <strong>3 pontos</strong></input>
                            <div></div>
                            <input type="checkbox"  name="checkPontuacao" value="2" onclick="calcularPontuacao();">RISCO � IMAGEM DA ECT = <strong>2 pontos</strong></input>
--->
                            
                            <div id="checkPontuacaoAGFdiv" style="margin-top:10px;visiblity:hidden;display:none">
                                Pontuação Adicional p/ AGF:<div></div> 
								<input  type="radio" id="" name="checkPontuacaoAGF" value="0" onClick="calcularPontuacao('0')" checked>Pontuação Inicial</input>								
								<div></div>
						        <cfoutput query="rsPta">
								   <cfif rsPta.PTC_Franquia is 'S'>
										 <input  type="radio" id="#rsPta.PTC_Seq#" name="checkPontuacaoAGF" value="#rsPta.PTC_Valor#" <cfif listFind('#rsItemFiltradoOutros.Itn_PTC_Seq#','#rsPta.PTC_Seq#') neq 0>checked</cfif> onClick="calcularPontuacao()">#rsPta.PTC_Descricao# = <strong>#rsPta.PTC_Valor# pontos</strong></input> 
									 <div></div> 
								   </cfif>
							      </cfoutput> 
								  <input type="hidden" name="teste2">
  <!---                               <select id="checkPontuacaoAGF" name="checkPontuacaoAGF" onchange="calcularPontuacao();">
                                    <option value=""  selected></option> 
                                    <option value="1">PONTUA��O PREVISTA NO CFP IGUAL A 0(ZERO) = <strong>1 ponto</strong></option>
                                    <option value="3">PONTUA��O PREVISTA NO CFP ENTRE 1 E 10 = <strong>3 pontos</strong></option>
                                    <option value="6">PONTUA��O PREVISTA NO CFP ENTRE 11 E 49 = <strong>6 pontos</strong></option>
                                    <option value="9" >PONTUA��O PREVISTA NO CFP MAIOR OU IGUAL A 50 = <strong>9 pontos</strong></option>
                                </select> --->
                               
                            </div>
            
                            <div id="totalDiv" style="visibility:hidden;margin-right:20px;margin-top:20px;float:left">
                                <span style="position:relative;top:-8px">Total: </span><strong><input type="text"  
                                id="pontuacaoCalculada" readonly  size="3"
                                style="font-size:26px;text-align:center;background:transparent;color:white;" value="<cfoutput>#rsItemFiltradoOutros.itn_pontuacao#</cfoutput>"></strong></input>
                            </div>

                            <div id="totalAGFdiv" style="visibility:hidden;margin-right:20px;margin-top:20px;float:left;visiblity:hidden;">
                                    <span style="position:relative;top:-8px">Total AGF: </span><strong><input type="text"  id="pontuacaoCalculadaAGF" readonly  size="3"
                                    style="font-size:26px;text-align:center;background:transparent;color:white;" value="<cfoutput>#rsItemFiltradoOutros.itn_pontuacao#</cfoutput>"></strong></input>
                            </div>
 
                            <div align="right" style="margin-top:20px;float:left">
                                <button onClick="calcularPontuacao();inserePontuacao()" onmouseOver="this.style.backgroundColor='cornflowerBlue';" onMouseOut="this.style.backgroundColor='blue';"
                                class="botaoCad" style="background:blue;color:#fff;font-size:12px;width:121px">Inserir Pontuação</button> 
                            </div>
                            <div align="right" style="margin-top:20px;">
                                <button onClick="fechaCalculadora()" onmouseOver="this.style.backgroundColor='red';" onMouseOut="this.style.backgroundColor='darkred';"
                                class="botaoCad" style="background:darkred;color:#fff;font-size:12px;width:65px">Fechar</button> 
                            </div>
                        </div>
                    </div>
                    <!---Fim Calculadora de Pontua��o--->
					</cfif>
            </form>


        </div>
    <style>
        .cke_top{
            <!---background:#003366; --->
        }
        



    </style>

    <script>
        <cfoutput>
            var filtro
        <cfif isDefined("form.selAltModalidade") and '#form.selAltModalidade#' neq '' and '#rsModFiltro.recordcount#' neq 0>
            filtro ='#rsModFiltro.recordcount#';
        </cfif>
        </cfoutput>

    if(filtro >0){
    // CKEDITOR.addCss('.cke_editable { background-color: #003366; color: white }');
        CKEDITOR.replace('altItemOrientacao', {
            width: '100%',
            height: 50,
            removePlugins: 'scayt',
            disableNativeSpellChecker: false,
            toolbar: [
                [ 'Preview', 'Print', '-' ],
                [ 'Cut', 'Copy', 'Paste', 'PasteText', 'RemoveFormat', '-', 'Undo', 'Redo', '-','Find','-','SelectAll'],
                [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-' ],
                [ 'NumberedList', 'BulletedList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
                 '/',
                ['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
                ['HorizontalRule','SpecialChar', '-', 'Styles', 'Font','FontSize','TextColor', 'BGColor', 'CreateDiv','-', 'Imagem', '-', 'Table','-', 'Maximize'  ]
            ]
        });
        

        CKEDITOR.replace('altItemPreRelato', {
            width: '100%',
            height: 50,
            removePlugins: 'scayt',
            disableNativeSpellChecker: false,
            toolbar: [
                ['Preview', 'Print', '-' ],
                [ 'Cut', 'Copy', 'Paste','PasteText', 'RemoveFormat', '-', 'Undo', 'Redo', '-','Find','-','SelectAll'],
                [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript' ],
                [ 'NumberedList', 'BulletedList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
                  '/',
                ['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
                ['HorizontalRule','SpecialChar', '-', 'Styles', 'Font','FontSize','TextColor', 'BGColor', 'CreateDiv','-', 'Imagem', '-', 'Table','-', 'Maximize'  ]
            ]
        });

        CKEDITOR.replace('altItemOrientacaoRelato', {
            width: '100%',
            height: 50,
            removePlugins: 'scayt',
            disableNativeSpellChecker: false,
            toolbar: [
                ['Preview', 'Print', '-' ],
                [ 'Cut', 'Copy', 'Paste','PasteText', 'RemoveFormat', '-', 'Undo', 'Redo', '-','Find','-','SelectAll'],
                [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript' ],
                [ 'NumberedList', 'BulletedList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
                '/',
                ['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
                ['HorizontalRule','SpecialChar', '-', 'Styles', 'Font','FontSize','TextColor', 'BGColor','Maximize'  ]
            ]
        });

        CKEDITOR.replace('altItemAmostra', {
            width: '400',
            height: 50,
            removePlugins: 'scayt',
            disableNativeSpellChecker: false,
            toolbar: [	
                [ 'Preview', 'Paste', 'PasteText', 'RemoveFormat' ,'-', 'Undo', 'Redo','-', 'Bold', 'Italic', '-', 'SelectAll','-','NumberedList', 'BulletedList','SpecialChar','-',
                'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','TextColor','Maximize','BGColor']
            ]				
        });

        CKEDITOR.replace('altItemNorma', {
            width: '400',
            height: 50,
            removePlugins: 'scayt',
            disableNativeSpellChecker: false,
            toolbar: [	
                [ 'Preview', 'Paste', 'PasteText', 'RemoveFormat',  '-', 'Undo', 'Redo','-', 'Bold', 'Italic', '-', 'SelectAll','-','NumberedList', 'BulletedList','SpecialChar','-',
                'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','TextColor','Maximize' ]
            ]		
        });

    }


    </script>
           
    </body>
   
</html>