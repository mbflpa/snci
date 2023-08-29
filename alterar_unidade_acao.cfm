<cfprocessingdirective pageEncoding ="utf-8"/>
<cftransaction>  <!--- Inclusão: Marcelo Bittencourt em 14/07/2020; DEMANDA: Update na unidade centralizadora; Se um UPDATE ou INSERT falhar, todas as alterações feitas terão roll back automático--->

<cfoutput>
  <cfquery name="rsReopAtu" datasource="#dsn_inspecao#">
           Select Und_CodReop  from Unidades WHERE Und_Codigo = '#form.codigo#'
  </cfquery>
  
  <!--- INCLUSÃO: Marcelo Bittencourt em 09/07/2020; DEMANDA: Update na unidade centralizadora---> 
	<!---Cria uma instância do componente Dao--->
	<cfobject component = "CFC/Dao" name = "dao">
  <!---Invoca o metodo  rsUsuarioLogado para retornar dados do usuário logado (rsUsuarioLogado)--->
	<cfinvoke component="#dao#" method="rsUsuarioLogado" returnVariable="rsUsuarioLogado">
  <!---Invoca o método 'rsUnidades' para retornar a unidade antes do update (qAtualizaUnidade)--->
	<cfinvoke component="#dao#" method="rsUnidadesSEusuario" returnVariable="rsUnidadeAntes" CodigoDaUnidade="#form.codigo#">
  <!---Invoca o método 'rsUnidades' para retornar a unidade centralizadora (rsUnidadeAntes.OrgaoCentralizador) antes do update (qAtualizaUnidade)--->	
<cfif IsDefined("form.centralizador")>	 
  
	<cfinvoke component="#dao#" method="rsUnidadesSEusuario" returnVariable="rsUnidadeCentralizaAntes" CodigoDaUnidade="#rsUnidadeAntes.OrgaoCentralizador#"> 
	<cfif "#rsUnidadeCentralizaAntes.CodigoUnidade#" neq "" >
		<cfset centralizadoraAntes = '#rsUnidadeAntes.OrgaoCentralizador#'>
     <cfelse>
		<cfset centralizadoraAntes = '#form.codigo#'>
	</cfif>		
</cfif>				
  <!--- Fim: Marcelo --->
 		  
  <!--- ALTERAÇÃO: Marcelo Bittencourt em 09/07/2020; DEMANDA: Update na unidade centralizadora---> 
  <cfif IsDefined("form.centralizador") and form.centralizador neq '' >		
        <cfquery name="qAtualizaUnidade" datasource="#dsn_inspecao#">
 UPDATE Unidades SET Und_Sigla='#form.sigla#',Und_Cgc='#form.CGC#',Und_Descricao='#form.descricao#',Und_TipoUnidade=#form.tipo#,Und_Cidade='#form.cidade#',Und_NomeGerente = '#form.gerente#', Und_CatOperacional = #form.categoria#, Und_Email = '#form.email#',Und_CodReop = '#form.reop#', Und_Endereco = '#form.endereco#', Und_Status = '#form.Status#', Und_Centraliza ='#form.centralizador#',Und_Username = '#rsUsuarioLogado.Username#', Und_DtUltAtu = convert(char, getdate(), 120)
                  WHERE Und_Codigo = '#form.codigo#'
        </cfquery>
   <cfelse>
	   <cfquery name="qAtualizaUnidade" datasource="#dsn_inspecao#">
 UPDATE Unidades SET Und_Sigla='#form.sigla#',Und_Cgc='#form.CGC#',Und_Descricao='#form.descricao#',Und_TipoUnidade=#form.tipo#,Und_Cidade='#form.cidade#',Und_NomeGerente = '#form.gerente#', Und_CatOperacional = #form.categoria#, Und_Email = '#form.email#',Und_CodReop = '#form.reop#', Und_Endereco = '#form.endereco#', Und_Status = '#form.Status#', Und_Username = '#rsUsuarioLogado.Username#', Und_DtUltAtu = convert(char, getdate(), 120)
                  WHERE Und_Codigo = '#form.codigo#'        
	  </cfquery>
   </cfif>
		
 
  <!--- Fim: Marcelo --->
  
  <!--- Atualizar Resultado_Inspecao --->
  <cfquery name="rsRIP" datasource="#dsn_inspecao#">
  SELECT RIP_Unidade, RIP_NumInspecao, RIP_NumGrupo, RIP_NumItem, RIP_CodReop FROM Resultado_Inspecao WHERE RIP_Unidade = '#form.codigo#'
</cfquery>
</cfoutput>
<!--- <cfset gil = gil> --->
<cfoutput query="rsRIP">
  <cfquery name="rsPOS" datasource="#dsn_inspecao#">
		 SELECT Pos_Area, Pos_NomeArea, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_Situacao_Resp FROM ParecerUnidade WHERE Pos_Unidade = '#form.codigo#' AND Pos_Inspecao = '#RIP_NumInspecao#' AND Pos_NumGrupo = #RIP_NumGrupo# AND Pos_NumItem = #RIP_NumItem# AND (Pos_Situacao_Resp <> 3 And Pos_Situacao_Resp <> 12 And Pos_Situacao_Resp <> 13)
  </cfquery>
  <cfif rsPos.recordcount gt 0>
    <cfquery datasource="#dsn_inspecao#">
		 UPDATE Resultado_Inspecao SET RIP_CodReop = '#form.reop#' where RIP_Unidade = '#form.codigo#' and RIP_NumInspecao = '#RIP_NumInspecao#' and RIP_NumGrupo = #RIP_NumGrupo# and RIP_NumItem = #RIP_NumItem#
	</cfquery>
  </cfif>
 </cfoutput> 
<!--- Fim --->
	  
<!--- Inclusão: Marcelo Bittencourt em 09/07/2020; DEMANDA: Update na unidade centralizadora --->
			
  <!---Compara o centralizador antes com o centralizador depois do update. A rotina será executada apenas se o usuário tiver alterado a unidade centralizadora, evitando Select e Update desnecessários, além de um Insert indevido no campo Pos_Parecer --->
	  
 <cfif IsDefined("form.centralizador") and form.centralizador neq '' >		 	  
	  
       <cfinvoke component="#dao#" method="rsUnidadesSEusuario" returnVariable="rsUnidadeDepois" CodigoDaUnidade="#form.codigo#">

       <cfinvoke component="#dao#" method="rsUnidadesSEusuario" returnVariable="rsUnidadeCentralizaDepois" CodigoDaUnidade="#form.centralizador#">


       <cfif '#rsUnidadeCentralizaDepois.CodigoUnidade#' neq "">
             <cfset centralizadoraDepois = '#rsUnidadeCentralizaDepois.CodigoUnidade#' >
             <cfset centralizadoraOrgSubDepois= '#rsUnidadeCentralizaDepois.OrgaoSubordinador#' >
       <cfelse>
             <cfset centralizadoraDepois = '#form.codigo#' >
              <cfset centralizadoraOrgSubDepois= '#rsUnidadeDepois.OrgaoSubordinador#' >	 
       </cfif>	


       <cfif "#centralizadoraAntes#" neq "#centralizadoraDepois#">

           <cfquery name="orgSubAntes" datasource="#dsn_inspecao#">
                  Select Rep_Codigo, Rep_Nome, Rep_CodArea From Reops Where Rep_Codigo = '#rsUnidadeCentralizaAntes.OrgaoSubordinador#' And Rep_Status = 'A'
           </cfquery>
           <cfset orgSubAntesCodigo = '#orgSubAntes.Rep_Codigo#'>
           <cfset orgSubAntesNome = '#orgSubAntes.Rep_Nome#'>	

           <cfquery name="areaAntes" datasource="#dsn_inspecao#">
                  Select Ars_Codigo, Ars_Descricao  From Areas Where Ars_Codigo = '#orgSubAntes.Rep_CodArea#' And Ars_Status = 'A'
           </cfquery>	 
           <cfset areaAntesCodigo = '#areaAntes.Ars_Codigo#'>
           <cfset areaAntesNome = '#areaAntes.Ars_Descricao#'>	 

      <!---Busca na tabela ParecerUnidade todos os itens da unidade (form.codigo) que possuem o Itn_TipoUnidade = 4 na tabela Itens_Verificacao e que 
      estão pendentes/tratamento de unidde, órgão subordinador e área--->
      <cfquery name="rsPOSalteraCentraliza" datasource="#dsn_inspecao#">
          SELECT Pos_Area, Pos_NomeArea, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem,Pos_Situacao, Pos_Situacao_Resp,
          Pos_Parecer, Pos_DtPrev_Solucao 
          FROM ParecerUnidade 
          INNER JOIN Itens_Verificacao ON ParecerUnidade.Pos_NumItem = Itens_Verificacao.Itn_NumItem AND ParecerUnidade.Pos_NumGrupo = Itens_Verificacao.Itn_NumGrupo
                     AND right([ParecerUnidade.Pos_Inspecao], 4) = Itens_Verificacao.Itn_Ano 
          WHERE Pos_Unidade = '#form.codigo#' AND Itens_Verificacao.Itn_TipoUnidade=4 AND (Pos_Situacao_Resp = 2 OR Pos_Situacao_Resp = 4 OR
          Pos_Situacao_Resp = 5 OR Pos_Situacao_Resp = 15 OR Pos_Situacao_Resp = 16 OR Pos_Situacao_Resp = 19  OR Pos_Situacao_Resp = 14 OR Pos_Situacao_Resp = 0 OR Pos_Situacao_Resp = 11)
      </cfquery>

      <cfquery name="rsInspecao" datasource="#dsn_inspecao#">
          Select INP_NumInspecao, INP_DtInicInspecao as dataInspecao From Inspecao Where INP_NumInspecao = '#rsPOSalteraCentraliza.Pos_Inspecao#' 	 
      </cfquery>	 

      <!---Verifica se exite, pelo menos, um item resultante da consulta rsPOSalteraCentraliza--->
       <cfif rsPOSalteraCentraliza.recordcount gt 0>
          <cfset mandaEmail = "yes"><!---Utilizado para enviar e-mail apenas na primeira ocorrência do status 14-NR--->
          <cfoutput query="rsPOSalteraCentraliza" > 

                    <cfset NomeUnidadeInspecionada ='#Trim(rsUnidadeAntes.Descricao)#'>
                    <cfset EmailUnidadeInspecionada ='#Trim(rsUnidadeAntes.Email)#'>  
                    <cfset CodigoDaUnidade = '#form.codigo#'>
                    <cfset NomeUnidadeCentralizaAntes = '#Trim(rsUnidadeCentralizaAntes.Descricao)#' >
                    <cfset NomeUnidadeCentralizaDepois = '#Trim(rsUnidadeCentralizaDepois.Descricao)#'>
                    <cfset EmailUnidadeCentralizaDepois = '#Trim(rsUnidadeCentralizaDepois.Email)#'>  

                    <cfif Trim(rsUsuarioLogado.GrupoAcesso) eq 'INSPETORES' || Trim(rsUsuarioLogado.GrupoAcesso) eq 'DESENVOLVEDORES'|| Trim(rsUsuarioLogado.GrupoAcesso) eq 'GESTORES'>
                       <cfset Responsavel = '#Trim(rsUsuarioLogado.Login)#' & ' (' & '#Trim(rsUsuarioLogado.NomeLotacao)#' & ')'>
                    <cfelse>
                       <cfset Responsavel = '#Trim(rsUsuarioLogado.Login)#' & '\' & '#Trim(rsUsuarioLogado.NomeUsuario)#' & ' (' & '#Trim(rsUsuarioLogado.NomeLotacao)#' & ')'>
                    </cfif>
                   <cfinvoke component="#dao#" method="dataNovoPrazo" returnVariable="dataNovoPrazo">		  
                   <cfset DataPrevisaoSolucao =  '#dataNovoPrazo#' >
                   <cfset situacao = '#rsPOSalteraCentraliza.Pos_Situacao_Resp#'>
                   <cfset situacaoSigla = '#rsPOSalteraCentraliza.Pos_Situacao#'>	
                    <cfquery name="rsSituacao_Ponto" datasource="#dsn_inspecao#">
                            Select STO_Descricao From Situacao_Ponto Where STO_Codigo = '#situacao#' 
                   </cfquery>	 
                   <cfset situacaoDescricao = '#rsSituacao_Ponto.STO_Descricao#'>		 
                   <cfif situacao EQ 15 ><!---Muda para PENDENTE DA UNIDADE---> 
                        <cfset situacaoDescricao = 'PENDENTE DA UNIDADE'>		 
                   </cfif>
                   <cfif situacao EQ 16 ><!---Muda para PENDENTE DO ORGAO SUBORDINADOR---> 
                        <cfset situacaoDescricao = 'PENDENTE DO ORGAO SUBORDINADOR'>		 
                   </cfif>
                   <cfif situacao EQ 19 ><!---Muda para PENDENTE DA UNIDADE---> 
                        <cfset situacaoDescricao = 'PENDENTE DE AREA'>		 
                   </cfif>		  



                   <cfquery name="orgSubDepois" datasource="#dsn_inspecao#">
                            Select Rep_Codigo, Rep_Nome, Rep_CodArea, Rep_Email From Reops Where Rep_Codigo = '#centralizadoraOrgSubDepois#' And Rep_Status = 'A'
                   </cfquery>
                   <cfset orgSubDepoisCodigo = '#orgSubDepois.Rep_Codigo#'	>
                   <cfset orgSubDepoisNome = '#orgSubDepois.Rep_Nome#'	>	
                   <cfset orgSubDepoisEmail = '#orgSubDepois.Rep_Email#'	>

                   <cfquery name="areaDepois" datasource="#dsn_inspecao#">
                            Select Ars_Codigo, Ars_Descricao  From Areas Where Ars_Codigo = '#orgSubDepois.Rep_CodArea#' And Ars_Status = 'A'
                   </cfquery>	 
                   <cfset areaDepoisCodigo = '#areaDepois.Ars_Codigo#'	>
                   <cfset areaDepoisNome = '#areaDepois.Ars_Descricao#'	>	 

                    <cfif situacao EQ 2 || situacao EQ 14 || situacao EQ 15 || situacao EQ 0 || situacao EQ 11>
                        <cfif '#form.centralizador#' eq "">
                             <cfset destMensagem	= '#NomeUnidadeInspecionada#'>
                             <cfset destEmail ='#EmailUnidadeInspecionada#'>   
                        <cfelse>
                             <cfset destMensagem	= '#NomeUnidadeCentralizaDepois#'>
                             <cfset destEmail ='#EmailUnidadeCentralizaDepois#'>	
                        </cfif>
                    </cfif>
                    <cfif situacao EQ 4 || situacao EQ 16>
                      <cfset destMensagem	= '#orgSubDepoisNome#'>
                    </cfif> 
                    <cfif situacao EQ 5 || situacao EQ 19>
                      <cfset destMensagem	= '#areaDepoisNome#'>
                    </cfif> 
                   <!---Mensagens--->
                    <cfset pos_aux_inicio = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & 
                             'Opinião do Controle Interno' & CHR(13) & CHR(13) &
                             'À(O) ' &  Trim('#destMensagem#') & CHR(13) & CHR(13) &
                             'Apontamento transferido para manifestação desse órgão em decorrência da ' >  
                    <cfset pos_aux_fim =  'Situação: ' & Trim('#situacaoDescricao#') & CHR(13) & CHR(13) &
                             'Data de Previsão da Solução: ' &  DateFormat('#dataNovoPrazo#',"dd/mm/yyyy") & CHR(13) & CHR(13) &
                             'Responsável: ' & '#Responsavel#' & CHR(13) & CHR(13) &
                              RepeatString('-',119)>

                    <!--Descentralização--->   
                    <cfif '#form.centralizador#' eq ""> 
                         <cfset pos_aux = '#pos_aux_inicio#' & 'descentralização da atividade de Distribuição Domiciliária. Favor adotar/apresentar as ações necessárias para o saneamento da Não Conformidade (NC) registrada.'& CHR(13) & CHR(13) & '#pos_aux_fim#'>
                         <cfset posArea = '#rsUnidadeAntes.CodigoUnidade#'>
                         <cfset posNomeArea = '#rsUnidadeAntes.Descricao#'>
                    <!--Centralização--->
                    <cfelseif	'#rsUnidadeCentralizaAntes.CodigoUnidade#' eq "">
                         <cfset pos_aux = '#pos_aux_inicio#' & 'centralização da atividade de Distribuição Domiciliária da unidade verificada: ' &  Trim('#NomeUnidadeInspecionada#')  & '. Favor adotar/apresentar as ações necessárias para o saneamento da Não Conformidade (NC) registrada.' & CHR(13) & CHR(13) & '#pos_aux_fim#'>
                         <cfset posArea = '#rsUnidadeCentralizaDepois.CodigoUnidade#'>
                         <cfset posNomeArea = '#rsUnidadeCentralizaDepois.Descricao#'>	   
                    <cfelse>
                    <!--Mudança de Centralizador--->
                        <cfset pos_aux = '#pos_aux_inicio#' & 'mudança da unidade de centralização da atividade de Distribuição Domiciliária da unidade verificada ' &  Trim('#NomeUnidadeInspecionada#') & ', mudando do ' & Trim('#NomeUnidadeCentralizaAntes#') & ' para ' & Trim('#NomeUnidadeCentralizaDepois#') & '. Favor adotar/apresentar as ações necessárias para o saneamento da Não Conformidade (NC) registrada.' & CHR(13) & CHR(13) & '#pos_aux_fim#'>
                        <cfset posArea = '#rsUnidadeCentralizaDepois.CodigoUnidade#'>
                        <cfset posNomeArea = '#rsUnidadeCentralizaDepois.Descricao#'>	  
                    </cfif>
                   <!--concatena pareceres anteriores ao pos_aux--->
                   <cfset pos_aux_hist = '#rsPOSalteraCentraliza.Pos_Parecer#' & CHR(13) & CHR(13) & '#pos_aux#'>
                  <!---De acordo com o tipo de situação realiza o apdate na tabela ParecerUnidade e um insert na tabela Andamento--->
                   <!-- se a situacao for pendente de unidade ou tratamento de unidade ou  Não Respondido--->	 
                   <cfif situacao EQ 2 || situacao EQ 14 || situacao EQ 15 || situacao EQ 0 || situacao EQ 11>
                         <!---Updade em ParecerUnidade--->
                         <cfquery datasource="#dsn_inspecao#">
                                  UPDATE ParecerUnidade SET Pos_Area = '#posArea#', Pos_NomeArea = '#posNomeArea#', Pos_DtPosic  = convert(char, getdate(), 102), 
                                  Pos_DtUltAtu = CONVERT(char, GETDATE(), 120), 
                                  <cfif situacao EQ 2 || situacao EQ 15>
                                      Pos_Parecer = '#pos_aux_hist#', 
                                      Pos_DtPrev_Solucao = #createodbcdate(createdate(year(DataPrevisaoSolucao),month(DataPrevisaoSolucao),day(DataPrevisaoSolucao)))#,
                                  </cfif>
                                  <cfif situacao EQ 15>
                                      Pos_Situacao = 'PU',
                                      Pos_Situacao_Resp = '2',
                                  </cfif>
                                  pos_username = '#Trim(rsUsuarioLogado.Login)#', Pos_NomeResp = '#Trim(rsUsuarioLogado.Login)#'
                                  WHERE Pos_Unidade = '#form.codigo#' AND Pos_Inspecao = '#Pos_Inspecao#' AND Pos_NumGrupo = '#Pos_NumGrupo#' AND Pos_NumItem = '#Pos_NumItem#' AND Pos_Situacao_Resp = '#situacao#' 
                         </cfquery>

                         <!---Insert em Andamento---> 
                         <!---0 e 11 não faz insert na Andamento--->
                         <cfif situacao EQ 2 || situacao EQ 14 || situacao EQ 15>
                               <!---Se em tratamento, mudar para pendente---> 
                               <cfif situacao EQ 15 || situacao EQ 16 || situacao EQ 19 >
                                      <cfset situacao = '2'>
                               </cfif>

                               <cfinvoke component="#dao#" method="insertAndamento"  
                                    NumeroDaInspecao = '#Pos_Inspecao#' CodigoDaUnidade = '#form.codigo#' Grupo = '#Pos_NumGrupo#' Item = '#Pos_NumItem#' CodigoDaSituacaoDoPonto = '#situacao#' Parecer ='#pos_aux#' CodigoUnidadeDaPosicao = '#posArea#'>	
                         </cfif>   
                           <!---Se o status for 14-NR--->

                          <cfif '#mandaEmail#' eq "yes" ><!---Para mandar e-mail apenas na ocorrência do primeiro item 14-NR--->
                                <cfif situacao EQ 14 >
                                    <!---Cria uma instância do componente Emails--->
                                    <cfobject component = "CFC/Emails" name = "email">

                                    <!---Invoca o metodo  SendMail_14NR para enviar e-mail a unidade centralizadora (centralização ou troca de centralizador) ou a AC (descentralização)--->
                                    <cfset dataInspecao = DateFormat('#rsInspecao.dataInspecao#',"DD/MM/YYYY") >	
                                    <cfinvoke component="#email#" method="SendMail_14NR" emailDestinatario="#destEmail#" numInspecao="#Pos_Inspecao#" dataInspecao="#dataInspecao#" codigoOrgao = "#posArea#" nomeOrgao="#destMensagem#"  nomeDestinatario="#destMensagem#"> 

                                    <!---Invoca o metodo  SendMail_14NR para enviar e-mail ao órgão subordinador--->
                                    <cfinvoke component="#email#" method="SendMail_14NR" emailDestinatario="#orgSubDepoisEmail#" numInspecao="#Pos_Inspecao#" dataInspecao="#dataInspecao#" codigoOrgao = "#posArea#" nomeOrgao="#destMensagem#" nomeDestinatario="#orgSubDepoisNome#" e_orgaoSubordinador="yes"> 
                                    <cfset mandaEmail = "no" ><!---Assim a variável mandaEmail "no" e o e-mail não será encaminhado novamente--->	
                                </cfif>	
                            </cfif>
                  </cfif>
                  <!--Se mudou o órgão subordinador---> 
                  <cfif '#orgSubAntesCodigo#' neq '#orgSubDepoisCodigo#'>	
                    <!-- se a situacao for pendente de orgao subordinador ou tratamento de órgão subordinador--->
                    <cfif situacao EQ 4 || situacao EQ 16 >

                         <!---Updade em ParecerUnidade--->
                         <cfquery datasource="#dsn_inspecao#">
                                  UPDATE ParecerUnidade SET Pos_Area = '#orgSubDepoisCodigo#', Pos_NomeArea = '#orgSubDepoisNome#', Pos_Parecer = '#pos_aux_hist#', Pos_DtPosic  = convert(char, getdate(), 102),
                                  <cfif situacao EQ 16>
                                      Pos_Situacao = 'PO',
                                      Pos_Situacao_Resp = '4',
                                  </cfif>
                                  Pos_DtUltAtu = CONVERT(char, GETDATE(), 120), Pos_DtPrev_Solucao = #createodbcdate(createdate(year(DataPrevisaoSolucao),month(DataPrevisaoSolucao),day(DataPrevisaoSolucao)))#,
                                  pos_username = '#Trim(rsUsuarioLogado.Login)#', Pos_NomeResp = '#Trim(rsUsuarioLogado.Login)#'
                                  WHERE Pos_Unidade = '#form.codigo#' AND Pos_Inspecao = '#Pos_Inspecao#' AND Pos_NumGrupo = '#Pos_NumGrupo#' AND Pos_NumItem = '#Pos_NumItem#'  AND Pos_Situacao_Resp = '#situacao#'  
                         </cfquery>
                         <!---Insert em Andamento--->
                         <cfinvoke component="#dao#" method="insertAndamento"  
                              NumeroDaInspecao = '#Pos_Inspecao#' CodigoDaUnidade = '#form.codigo#' Grupo = '#Pos_NumGrupo#' Item = '#Pos_NumItem#'  CodigoDaSituacaoDoPonto = '#situacao#'
                              Parecer ='#pos_aux#' CodigoUnidadeDaPosicao = '#orgSubDepois.Rep_Codigo#'>	
                    </cfif>
                    <!--se mudou a área e a área do Pos_Area for gestora da unidade anterior--->  
                    <cfif '#areaAntesCodigo#' neq '#areaDepoisCodigo#' AND '#rsPOSalteraCentraliza.Pos_Area#' eq '#areaAntesCodigo#'>
                      <!-- se a situacao for pendente de área ou tratamento de área--->
                      <cfif situacao EQ 5 || situacao EQ 19 >
                             <!---Updade em ParecerUnidade--->
                             <cfquery datasource="#dsn_inspecao#">
                                      UPDATE ParecerUnidade SET Pos_Area = '#areaDepoisCodigo#', Pos_NomeArea = '#areaDepoisNome#', Pos_Parecer = '#pos_aux_hist#', Pos_DtPosic  = convert(char, getdate(), 102),
                                      <cfif situacao EQ 19>
                                          Pos_Situacao = 'PA',
                                          Pos_Situacao_Resp = '5',
                                      </cfif>
                                      Pos_DtUltAtu = CONVERT(char, GETDATE(), 120), Pos_DtPrev_Solucao = #createodbcdate(createdate(year(DataPrevisaoSolucao),month(DataPrevisaoSolucao),day(DataPrevisaoSolucao)))#,
                                      pos_username = '#Trim(rsUsuarioLogado.Login)#', Pos_NomeResp = '#Trim(rsUsuarioLogado.Login)#'
                                      WHERE Pos_Unidade = '#form.codigo#' AND Pos_Inspecao = '#Pos_Inspecao#' AND Pos_NumGrupo = '#Pos_NumGrupo#' AND Pos_NumItem = '#Pos_NumItem#' AND Pos_Situacao_Resp = '#situacao#' 
                             </cfquery>
                             <!---Insert em Andamento--->
                             <cfinvoke component="#dao#" method="insertAndamento"  
                                  NumeroDaInspecao = '#Pos_Inspecao#' CodigoDaUnidade = '#form.codigo#' Grupo = '#Pos_NumGrupo#' Item = '#Pos_NumItem#' CodigoDaSituacaoDoPonto = '#situacao#'
                                  Parecer ='#pos_aux#' CodigoUnidadeDaPosicao = '#areaDepois.Ars_Codigo#'>
                       </cfif>	
                    </cfif>
                 </cfif>

          </cfoutput>
       </cfif>
      </cfif>
</cfif>	
       <!--- Fim: Marcelo --->			


      <!--- Atualizar ParecerUnidade --->
      <cfquery name="rsArea" datasource="#dsn_inspecao#">
               SELECT Pos_Area, Pos_NomeArea, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_Situacao_Resp 
               FROM ParecerUnidade 
               WHERE Pos_Area = '#rsReopAtu.Und_CodReop#' AND Pos_Unidade = '#form.codigo#' AND Pos_Inspecao = '#rsRIP.RIP_NumInspecao#' AND Pos_Situacao_Resp <> 0 AND Pos_Situacao_Resp <> 11 AND Pos_Situacao_Resp <> 3 And Pos_Situacao_Resp <> 12 And Pos_Situacao_Resp <> 13
      </cfquery>
      <cfoutput query="rsArea">
        <cfquery name="rsREOP" datasource="#dsn_inspecao#">
                 SELECT Rep_Nome FROM Reops WHERE Rep_Codigo = '#form.reop#'
        </cfquery>
        <cfquery datasource="#dsn_inspecao#">
                UPDATE ParecerUnidade SET Pos_Area = '#form.reop#', Pos_NomeArea = '#rsREOP.Rep_Nome#', Pos_DtUltAtu = CONVERT(char, GETDATE(), 120) WHERE Pos_Unidade = '#form.codigo#' and Pos_Inspecao = '#rsArea.Pos_Inspecao#' and Pos_NumGrupo = #rsArea.Pos_NumGrupo# and Pos_NumItem = #rsArea.Pos_NumItem#
        </cfquery>
      </cfoutput>

	
<!--- Fim --->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Sistema de Acompanhamento das Respostas das Auditorias</title>
<cfinclude template="cabecalho.cfm">
<link href="CSS.css" rel="stylesheet" type="text/css">
<script language="JavaScript" type="text/JavaScript">
	function voltar(){
	  document.formvolta.submit();
	}
</script>
</head>
<body>
<form action="alterar_unidade.cfm">
  <div align="center" class="style1"></div>
  <br>
  <br>
  <tr>
    <table width="90%">
      <tr>
        <td align="center"><span style="color:#004586;font-size: 20px">Caro Usu&aacute;rio, sua opera&ccedil;&atilde;o de altera&ccedil;&atilde;o foi realizada com sucesso!!! </span></td>
      </tr>
      <tr>
        <td align="center">&nbsp;</td>
      </tr>
      
        <td align="center">
			<input  name="cancelar" class="botao" type="button" value="Voltar" onClick="voltar()">
          &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <input type="button" class="botao" onClick="window.close()" value="Fechar">
		</td>
      </tr>
    </table>
 <input name="se" type="hidden" value="<cfoutput>#form.se#</cfoutput>">
</form>
<form name="formvolta" method="post" action="alterar_unidade.cfm">
  <input name="tpunid" id="tpunid" type="hidden" value="<cfoutput>#form.tipo#</cfoutput>">
  <input name="se" type="hidden" value="<cfoutput>#form.se#</cfoutput>">
</form>
</body>
</html>
</cftransaction>