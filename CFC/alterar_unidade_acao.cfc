<cfcomponent >
  <cfprocessingdirective pageencoding = "utf-8">	
<cffunction name="acao">
	<cftransaction>  <!--- Inclus�o: Marcelo Bittencourt em 14/07/2020; DEMANDA: Update na unidade centralizadora; Se um UPDATE ou INSERT falhar, todas as altera��es feitas ter�o roll back autom�tico--->
<cfoutput>
  <cfquery name="rsReopAtu" datasource="#dsn_inspecao#">
           Select Und_CodReop  from Unidades WHERE Und_Codigo = '#form.codigo#'
  </cfquery>
  
  <!--- INCLUS�O: Marcelo Bittencourt em 09/07/2020; DEMANDA: Update na unidade centralizadora---> 
   
  <!---Cria uma inst�ncia do componente Dao--->
	<cfobject component = "CFC/Dao" name = "dao">
  <!---Invoca o metodo  rsUsuarioLogado para retornar dados do usu�rio logado (rsUsuarioLogado)--->
	<cfinvoke component="#dao#" method="rsUsuarioLogado" returnVariable="rsUsuarioLogado">
  <!---Invoca o m�todo 'rsUnidades' para retornar a unidade antes do update (qAtualizaUnidade)--->
	<cfinvoke component="#dao#" method="rsUnidadesSEusuario" returnVariable="rsUnidadeAntes" CodigoDaUnidade="#form.codigo#">
  <!---Invoca o m�todo 'rsUnidades' para retornar a unidade centralizadora (rsUnidadeAntes.OrgaoCentralizador) antes do update (qAtualizaUnidade)--->
	<cfinvoke component="#dao#" method="rsUnidadesSEusuario" returnVariable="rsUnidadeCentralizaAntes" CodigoDaUnidade="#rsUnidadeAntes.OrgaoCentralizador#">	
 
  <!--- Fim: Marcelo --->
 		  
  <!--- ALTERA��O: Marcelo Bittencourt em 09/07/2020; DEMANDA: Update na unidade centralizadora---> 

  <cfquery name="qAtualizaUnidade" datasource="#dsn_inspecao#">
           UPDATE Unidades SET Und_NomeGerente = '#form.gerente#', Und_CatOperacional = #form.categoria#, Und_Email = '#form.email#',
	       Und_CodReop = '#form.reop#', Und_Endereco = '#form.endereco#', Und_Status = '#form.Status#', Und_Centraliza ='#form.centralizador#', 
	       Und_Username = '#rsUsuarioLogado.Username#', Und_DtUltAtu = convert(char, getdate(), 102)    
            WHERE Und_Codigo = '#form.codigo#'
  </cfquery>
		
 
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
	  
<!--- Inclus�o: Marcelo Bittencourt em 09/07/2020; DEMANDA: Update na unidade centralizadora --->
  

<!---Busca na tabela ParecerUnidade todos os itens da unidade (form.codigo) que possuem o Itn_TipoUnidade = 4 na tabela Itens_Verificacao --->
<cfquery name="rsPOSalteraCentraliza" datasource="#dsn_inspecao#">
  SELECT Pos_Area, Pos_NomeArea, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_Situacao_Resp,
    Pos_Parecer, Pos_DtPrev_Solucao 
	FROM ParecerUnidade 
	INNER JOIN Unidades ON Und_Codigo = Pos_Unidade
	INNER JOIN Inspecao ON Pos_Unidade = INP_Unidade AND Pos_Inspecao = INP_NumInspecao
	INNER JOIN Itens_Verificacao ON Pos_NumItem = Itn_NumItem AND 
	Pos_NumGrupo = Itn_NumGrupo and right(Pos_Inspecao,4) = Itn_Ano and (Itn_TipoUnidade = Und_TipoUnidade) AND (INP_Modalidade = Itn_Modalidade)
	WHERE Pos_Unidade = '#form.codigo#' AND Itn_TipoUnidade=4 AND Pos_Situacao_Resp = 2
</cfquery>
	  
<!---Verifica se exite, pelo menos, um item resultante da consulta rsRIP_Centraliza--->
 <cfif rsPOSalteraCentraliza.recordcount gt 0>
   <!---Percorre todos os itens resultantes da consulta rsRIP_Centraliza --->
   <cfoutput query="rsPOSalteraCentraliza">
   <cfinvoke component="#dao#" method="rsUnidadesSEusuario" returnVariable="rsUnidadeCentralizaDepois" CodigoDaUnidade="#form.centralizador#">
  <!---Compara o centralizador do form(form.centralizador) com o centralizador da tabela Unidades(rsUnidadeAntes.OrgaoCentralizador) antes do update(qAtualizaUnidade). A rotina ser� executada apenas se o usu�rio tiver alterado a unidade centralizadora, evitando Selects e Updadtes desnecess�rios, al�m de um Insert indevido no campo Pos_Parecer --->
  <cfif '#form.centralizador#' neq '#rsUnidadeAntes.OrgaoCentralizador#'>
    <!---Retorna o(s) item(ns) pendente(s) de unidade(Pos_Situacao_Resp = 2) na tabela ParecerUnidade--->
    
    <!---Verifica se exite, pelo menos, um item pendente de unidade na tabela ParecerUnidade. Se existir, executa a rotina de update na tabela ParecerUnidade--->
	  <cfif rsPOSalteraCentraliza.recordcount gt 0>
	      <cfset NomeUnidadeInspecionada ='#Trim(rsUnidadeAntes.Descricao)#'>
		  <cfset CodigoDaUnidade = '#form.codigo#'>
          <cfset NomeUnidadeCentralizaAntes = '#Trim(rsUnidadeCentralizaAntes.Descricao)#' >
		  <cfset NomeUnidadeCentralizaDepois = '#Trim(rsUnidadeCentralizaDepois.Descricao)#'>
		  <cfif Trim(rsUsuarioLogado.GrupoAcesso) eq 'INSPETORES' || Trim(rsUsuarioLogado.GrupoAcesso) eq 'DESENVOLVEDORES'|| Trim(rsUsuarioLogado.GrupoAcesso) eq 'GESTORES'>
		     <cfset Responsavel = '#Trim(rsUsuarioLogado.Login)#' & ' (' & '#Trim(rsUsuarioLogado.NomeLotacao)#' & ')'>
		  <cfelse>
		     <cfset Responsavel = '#Trim(rsUsuarioLogado.Login)#' & '\' & '#Trim(rsUsuarioLogado.NomeUsuario)#' & ' (' & '#Trim(rsUsuarioLogado.NomeLotacao)#' & ')'>
		  </cfif>
		 <cfinvoke component="#dao#" method="dataNovoPrazo" returnVariable="dataNovoPrazo">		  
		 <cfset DataPrevisaoSolucao = '#dataNovoPrazo#' >
		  
		 <cfif '#form.centralizador#' eq "">
               <cfset pos_aux = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & 
				   'Opini�o do Controle Interno' & CHR(13) & CHR(13) &
                   '�(O) ' &  Trim('#NomeUnidadeInspecionada#') & CHR(13) & CHR(13) &
                   'Apontamento transferido para manifesta��o desse �rg�o em decorr�ncia da descentraliza��o da atividade de Distribui��o Domicili�ria. Favor adotar/apresentar as a��es necess�rias para o saneamento da N�o Conformidade (NC) registrada.'& CHR(13) & CHR(13) &
                   'Situa��o: PENDENTE DA UNIDADE'& CHR(13) & CHR(13) &
                   'Data de Previs�o da Solu��o: ' &  '#DataPrevisaoSolucao#' & CHR(13) & CHR(13) &
                   'Respons�vel: ' & '#Responsavel#' & CHR(13) & CHR(13) &
				   RepeatString('-',119) >
			   <cfset posArea = '#rsUnidadeAntes.CodigoUnidade#'>
			   <cfset posNomeArea = '#rsUnidadeAntes.Descricao#'>

          <cfelseif	'#rsUnidadeCentralizaAntes.CodigoUnidade#' eq "">
               <cfset pos_aux = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & 
                   'Opini�o do Controle Interno' & CHR(13) & CHR(13) &
                   '�(O) ' &  Trim('#NomeUnidadeCentralizaDepois#') & CHR(13) & CHR(13) &
                   'Apontamento transferido para manifesta��o desse �rg�o em decorr�ncia da centraliza��o da atividade de Distribui��o Domicili�ria da unidade verificada: ' &  Trim('#NomeUnidadeInspecionada#')  & '. Favor adotar/apresentar as a��es necess�rias para o saneamento da N�o Conformidade (NC) registrada.'& CHR(13) & CHR(13) &
                   'Situa��o: PENDENTE DA UNIDADE'& CHR(13) & CHR(13) &
                   'Data de Previs�o da Solu��o: ' &  '#DataPrevisaoSolucao#' & CHR(13) & CHR(13) &
                   'Respons�vel: ' & '#Responsavel#' & CHR(13) & CHR(13) &
                    RepeatString('-',119) >
			   <cfset posArea = '#rsUnidadeCentralizaDepois.CodigoUnidade#'>
			   <cfset posNomeArea = '#rsUnidadeCentralizaDepois.Descricao#'>	   
		  <cfelse>
			  <cfset pos_aux = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & 
                   'Opini�o do Controle Interno' & CHR(13) & CHR(13) &
                   '�(O) ' &  Trim('#NomeUnidadeCentralizaDepois#') & CHR(13) & CHR(13) &
                   'Apontamento transferido para manifesta��o desse �rg�o em decorr�ncia da mudan�a da unidade de centraliza��o da atividade de Distribui��o Domicili�ria da unidade verificada ' &  Trim('#NomeUnidadeInspecionada#') & ', mudando do ' & Trim('#NomeUnidadeCentralizaAntes#') & ' para ' & Trim('#NomeUnidadeCentralizaDepois#') & '. Favor adotar/apresentar as a��es necess�rias para o saneamento da N�o Conformidade (NC) registrada.'& CHR(13) & CHR(13) &
                   'Situa��o: PENDENTE DA UNIDADE'& CHR(13) & CHR(13) &
                   'Data de Previs�o da Solu��o: ' &  '#DataPrevisaoSolucao#' & CHR(13) & CHR(13) &
                   'Respons�vel: ' & '#Responsavel#' & CHR(13) & CHR(13) &
                    RepeatString('-',119) >
			 	
			  <cfset posArea = '#rsUnidadeCentralizaDepois.CodigoUnidade#'>
			  <cfset posNomeArea = '#rsUnidadeCentralizaDepois.Descricao#'>	  
          </cfif>
 
		  <cfset pos_aux_hist = '#rsPOSalteraCentraliza.Pos_Parecer#' & CHR(13) & CHR(13) & '#pos_aux#'>
		  <cfquery datasource="#dsn_inspecao#">
				  UPDATE ParecerUnidade SET Pos_Area = '#posArea#', Pos_NomeArea = '#posNomeArea#', Pos_Parecer = '#pos_aux_hist#', Pos_DtPosic  = convert(char, getdate(), 102), pos_dtultatu = getdate() 
			      WHERE Pos_Unidade = '#form.codigo#' AND Pos_Inspecao = '#Pos_Inspecao#' AND Pos_NumGrupo = '#Pos_NumGrupo#' AND Pos_NumItem = '#Pos_NumItem#'  
		 </cfquery>	
			

<!--		Executa insert na tabela Andamento	-->
		<cfif '#form.centralizador#' eq "">
			<cfinvoke component="#dao#" method="insertAndamento"  
			  NumeroDaInspecao = '#Pos_Inspecao#' CodigoDaUnidade = '#form.codigo#' Grupo = '#Pos_NumGrupo#' Item = '#Pos_NumItem#' DominioMatriculaUsuario = '#Trim(rsUsuarioLogado.Login)#'  CodigoDaSituacaoDoPonto = '2'
			  Parecer ='#pos_aux#' CodigoUnidadeDaPosicao = '#Trim(rsUnidadeAntes.CodigoUnidade)#' >		  
		<cfelse>
			<cfinvoke component="#dao#" method="insertAndamento"  
			  NumeroDaInspecao = '#Pos_Inspecao#' CodigoDaUnidade = '#form.codigo#' Grupo = '#Pos_NumGrupo#' Item = '#Pos_NumItem#' DominioMatriculaUsuario = '#Trim(rsUsuarioLogado.Login)#' CodigoDaSituacaoDoPonto = '2'
			  Parecer ='#pos_aux#' CodigoUnidadeDaPosicao = '#Trim(rsUnidadeCentralizaDepois.CodigoUnidade)#'>	  
		</cfif>
                

    </cfif>
  </cfif>
 
</cfoutput>
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
          UPDATE ParecerUnidade SET Pos_Area = '#form.reop#', Pos_NomeArea = '#rsREOP.Rep_Nome#' WHERE Pos_Unidade = '#form.codigo#' and Pos_Inspecao = '#rsArea.Pos_Inspecao#' and Pos_NumGrupo = #rsArea.Pos_NumGrupo# and Pos_NumItem = #rsArea.Pos_NumItem#
  </cfquery>
</cfoutput>
	
</cftransaction>	
</cffunction>
<!--- Fim --->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Sistema de Acompanhamento das Respostas das Auditorias</title>

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
        <td align="center"><span class="red_titulo">Caro Usu&aacute;rio, sua opera&ccedil;&atilde;o de altera&ccedil;&atilde;o foi realizada com sucesso!!! </span></td>
      </tr>
      <tr>
        <td align="center">&nbsp;</td>
      </tr>
      
        <td align="center"><input name="cancelar" class="botao" type="button" value="Voltar" onClick="voltar()">
          
          <!--- <input name="cancelar" class="botao" type="button" value="Voltar" onClick="history.back(-3)"> --->&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <input type="button" class="botao" onClick="window.close()" value="Fechar"></td>
      </tr>
    </table>
    <!--- <input name="tpunid" id="tpunid" type="hidden" value="<cfoutput>#form.tipo#</cfoutput>"> --->
</form>
<form name="formvolta" method="post" action="alterar_unidade.cfm">
  <input name="tpunid" id="tpunid" type="hidden" value="<cfoutput>#form.tipo#</cfoutput>">
</form>
</body>
</html>
</cfcomponent >