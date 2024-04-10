<cfparam name="opcao" default="vazio"> 
  <cfset vAcesso = true>
   <cfif Not ListContains(Lista_SINS,UCase(cgi.REMOTE_USER))>
   <table width="100%" border="0" cellpadding="0" cellspacing="0">
     <tr>
      <td height="60"><img src="topoginsp.jpg" width="780" height="60"></td>
     </tr>
   </table> 
      <cfinclude template="permissao_negada.htm">
	  <cfset vAcesso = false>
   <cfabort>
  </cfif>  
<html>
<head>
<link href="css.css" rel="stylesheet" type="text/css">
<title>Sistema Nacional de Controle Interno</title>
</head>
<body>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
 <cfinclude template="cabecalho.cfm">
</table>
<table id="tabIndex" width="100%" height="30%" border="0" align="center" cellpadding="0" cellspacing="0">
  <tr valign="top">
   <td width="25%">
  <cfif vAcesso is true>
    <cfinclude template="menu_sins.cfm">
 </cfif>
	</td>
    <td align="center" valign="top">
	 <table width="100%" border="0" cellspacing="0" cellpadding="4">
      <tr>
	  <tr>
           <td>&nbsp;</td>
      </tr>
		<tr>
           <td>&nbsp;</td>
        </tr>
        <td>
		<cfswitch expression="#opcao#">
		<cfcase value="questionario">
	  	<cfinclude template="questionario_estatistica_media_coldfusion.htm">
	  	</cfcase>
		<cfcase value="questionario1">
	  		<cfinclude template="questionario_estatistica_importante.htm">
	  	</cfcase>
		<cfcase value="questionario2">
	  		<cfinclude template="estatistica_pesquisa_ref.cfm">
	  	</cfcase>
		<cfcase value="consulta">
	  		<cfinclude template="consulta_numero_ant.cfm">
	  	</cfcase>
		<cfcase value="consulta1">
	  		<cfinclude template="questionario_consulta_inspecao.htm">
		</cfcase>
        <cfcase value="consulta2">
	  		<cfinclude template="ControleEmail.cfm">
	  	</cfcase>
		<cfcase value="consulta3">
	  		<cfinclude template="itens_controle_pesquisa_ref.cfm">
	  	</cfcase>

		<cfcase value="inspecao">
	  		<cfinclude template="itens_verif_orgao.cfm">
	  	</cfcase>

		<cfcase value="inspecao1">
	  		<cfinclude template="itens_verif_mensal_ref.cfm">
	  	</cfcase>

		<cfcase value="inspecao2">
	  		<cfinclude template="itens_controle_respostas_ref.cfm">
	  	</cfcase>

		<cfcase value="inspecao3">
	  		<cfinclude template="itens_controle_pontosbaixados_ref.cfm">
	  	</cfcase>

		<cfcase value="inspecao4">
	  		<cfinclude template="gerar_causasprovaveis.cfm"> 
	  	</cfcase>

		<cfcase value="inspecao5">
	  		<cfinclude template="estatistica_itens_nao_conformes_ref.cfm">
	  	</cfcase>

		<cfcase value="inspecao6">
	  		<cfinclude template="estatistica_itens_nao_conformes_area_ref.cfm">
	  	</cfcase>

		<cfcase value="inspecao7">
	  		<cfinclude template="estatistica_itens_nao_conformes_reop_ref.cfm">
	  	</cfcase>

		<cfcase value="inspecao8">
	  		<cfinclude template="estatistica_atividade_ref.cfm">
	  	</cfcase>

		<cfcase value="inspecao9">
	  		<cfinclude template="itens_relevantes_ref.cfm">
	  	</cfcase>

		<cfcase value="inspecao10">
	  		<cfinclude template="itens_controle_respostas_corporativo_ref.cfm">
	  	</cfcase>

		<cfcase value="inspecao11">
	  		<cfinclude template="itens_controle_respostas_tipo_unidade_ref.cfm">
	  	</cfcase>

		<cfcase value="inspecao12">
	  		<cfinclude template="estatistica_tempo_gerencias_ref.cfm">
	  	</cfcase>

		<cfcase value="inspecao13">
	  		<cfinclude template="estatistica_tempo_areas_ref.cfm">
	  	</cfcase>
		
		<cfcase value="inspecao14">
	  		<cfinclude template="itens_controle_respostas_solucionado_ref.cfm">
	  	</cfcase>

		<cfcase value="inspecao15">
	  		<cfinclude template="estatistica_inspetores_ref.cfm">
	  	</cfcase>
		
		<cfcase value="inspecao16">
	  		<!--- <cfinclude template="itens_BI_Gestao_respostas_ref.cfm"> --->
			<cfinclude template="Itens_Analise_Manifestacao_ref.cfm">
	  	</cfcase>
		
		<cfcase value="inspecao18">
	  		<cfinclude template="itens_controle_revisliber_ref.cfm">
	  	</cfcase>
		
 		<cfcase value="inspecao19">
	  		<cfinclude template="relatorio_acompanhamento_auditoria_ref.cfm">
	  	</cfcase> 		
		
		<cfcase value="inspecao20">
	  <!---		<cfinclude template="slnc_Ref.cfm"> --->
			<cfinclude template="Rel_Indicadores_Solucao_Ref.cfm">
	  	</cfcase>
		
		<cfcase value="inspecao17">
		<!---	<cfinclude template="prci_ref.cfm"> --->
			<cfinclude template="itens_Gestao_Andamento_ref.cfm">
		</cfcase>
		
		<cfcase value="inspecao21">
	  		<cfinclude template="Rel_ClassifInspecao_Ref.cfm">
	  	</cfcase>	
		
		<cfcase value="inspecao22">
	<!---  		<cfinclude template="dgci_Ref.cfm"> --->
			<cfinclude template="se_indicadores_Ref.cfm">
	  	</cfcase>					
		
        <cfcase value="permissao0">
	  		<cfinclude template="alterar_unidade_ref.cfm">
	  	</cfcase>
		
<!--- 		<cfcase value="permissao1">
	  		<cfinclude template="excluir_inspecao_ref.cfm">
	  	</cfcase> --->

		<cfcase value="permissao">
	  		<cfinclude template="adicionar_permissao_rotinas_inspecao.cfm">
	  	</cfcase>

		<cfcase value="permissao2">
	  		<cfinclude template="alterar_area.cfm">
	  	</cfcase>

		<cfcase value="permissao3">
	  		<cfinclude template="alterar_reop.cfm">
	  	</cfcase>

		<cfcase value="permissao4">
	  		<cfinclude template="alterar_unidade.cfm">
	  	</cfcase>

		<cfcase value="permissao5">
	  		<cfinclude template="alterar_funcionario.cfm">
	  	</cfcase>

		<cfcase value="permissao6">
	  		<cfinclude template="relatorio_preliminar_auditoria_ref.cfm">
	  	</cfcase>

<!--- 		<cfcase value="permissao7">
	  		<cfinclude template="relatorio_acompanhamento_auditoria_ref.cfm">
	  	</cfcase> --->

		<cfcase value="permissao8">
	  		<cfinclude template="relatorio_acompanhamento_auditoria_dr_ref.cfm">
	  	</cfcase>

		<cfcase value="permissao9">
	  		<cfinclude template="relatorio_auditoria_area_ref.cfm">
	  	</cfcase>

		<cfcase value="permissao10">
	  		<cfinclude template="relatorio_preliminar_area_ref.cfm">
	  	</cfcase>

		<cfcase value="permissao11">
	  		<cfinclude template="relatorio_preliminar_DR_ref.cfm">
	  	</cfcase>

		<cfcase value="permissao12">
	  		<cfinclude template="relatorio_preliminar_objetivo_ref.cfm">
	  	</cfcase>

		<cfcase value="permissao13">
	  		<cfinclude template="relatorio_acompanhamento_auditoria_objetivo_ref.cfm">
	  	</cfcase>
		
		<cfcase value="permissao14">
	  		<cfinclude template="Itens_ajustaremlote.cfm">
	  	</cfcase>

        <cfcase value="permissao15">
			  <cfinclude template="avisosgrupos_geral.cfm">
	  	</cfcase>
        <cfcase value="permissao18">
			  <cfinclude template="Pesquisa_ref.cfm">
	  	</cfcase>	
		<cfcase value="permissao19">
			  <cfinclude template="Pacin_Unidades_Avaliadas_ref.cfm">
	  	</cfcase>	
		<cfcase value="permissao20">
			  <cfinclude template="Pacin_ClassificacaoUnidade_ref.cfm">
	  	</cfcase>
		<cfcase value="permissao21">
			  <cfinclude template="Pacin_Permuta_Avaliacao_ref.cfm">
	  	</cfcase>	
		<cfcase value="permissao22">
			<cfinclude template="Pacin_Permuta_Avaliacao_refb.cfm">
		</cfcase>	
		<cfcase value="permissao27">
			<cfinclude template="Pacin_GrupoItemReincidem_ref.cfm">
		</cfcase>			
<!--- 	    <cfcase value="permissao16">
			<cfinclude template="Rel_itensverificacao_ref.cfm">
		</cfcase> --->
<!--- 		<cfcase value="permissao17">
			  <cfinclude template="Grafico_Gestores_Pontos.cfm">
	  	</cfcase> --->
		<cfdefaultcase>
				
		<center>
		  <br><br><br><br>
		  <img src="GINSPLOGO.jpg" align="absbottom">
		</center>
		</cfdefaultcase>
	</cfswitch>
	</td>
   </tr>
</td>
  </table>
</body>
</html>
<cfif Ucase(CGI.REMOTE_USER) is 'PE\DESENVOLVEDOR'>
	<!---<cfdirectory directory="#GetDirectoryFromPath(GetTemplatePath())#\respostas_acf" name = "pasta" filter="*.xml">--->
	<cfdirectory directory="#servidor_ftp#" name = "pasta" filter="*.xml">
	<cfif pasta.recordcount neq 0>
		<script>
		  window.open('arquivo_dbins_visualizar_parecer_acf.cfm','_blank');
		</script>
	</cfif>
</cfif>

<script>
	window.onload = function() {
		// Obtém o nome do host e o caminho da página atual
		var currentHost = window.location.hostname;
		var currentPath ="/snci/index.cfm";

		// Constrói a URL de destino
		var targetUrl = "microsoft-edge:" + currentHost + currentPath;

		if (window.navigator.userAgent.indexOf("MSIE ") > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./)) {

				window.location.href = targetUrl;
			
		}
	}

</script>