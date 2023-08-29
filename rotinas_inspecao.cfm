<!--- 
<cflocation url="SNCI_MENSAGEM.cfm?form.motivo=Prezados Usuarios, por motivos tecnicos estamos fazendo uma manutencao urgentissima no Sistema SNCI, previsao de retorno no dia 28/03/2022, as 13:00h!">
 --->

 <script>
var txt = navigator.appName;
if (txt != 'Microsoft Internet Explorer')
{
// alert('Senhor(a) Usuário(a), O Sistema Nacional de Controle Interno - SNCI \ndeve ser utilizado apenas com o navegador: Microsoft Internet Explorer');
 alert('Senhor(a) Usuário(a), O Sistema Nacional de Controle Interno - SNCI \ndeve ser utilizado apenas com o navegador: Microsoft Internet Explorer\n em outro navegador algum recurso de página poderá ter o seu funcionamento inadequado!');

// window.location.href = "http://intranetsistemaspe/snci/";
}
//================
function abrirPopup(url,w,h) {
var newW = w + 100;
var newH = h + 100;
var left = (screen.width-newW)/2;
var top = (screen.height-newH)/2;
var newwindow = window.open(url, 'name', 'width='+newW+',height='+newH+',left='+left+',top='+top+ ',toolbar=no,location=no, directories=no, status=no, menubar=no, scrollbars=1, resizable=yes, copyhistory=no');
newwindow.resizeTo(newW, newH);
 
//posiciona o popup no centro da tela
newwindow.moveTo(left, top);
newwindow.focus();
return false;
}
//================
function pesquisa() {
//alert(document.formx.ninsp.value);
if (document.formx.ninsp.value != ''){
	document.formx.submit();
	}
}
</script>


<cfquery name="qUsuario" datasource="#dsn_inspecao#">
   SELECT DISTINCT Usu_GrupoAcesso, Usu_Matricula, Usu_Lotacao FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#'
</cfquery>

<cfset auxdt = createodbcdate(CreateDate(year(now()),month(now()),day(now())))>
<cfquery name="rsAviso" datasource="#dsn_inspecao#">
SELECT AVGR_ANO, AVGR_ID, AVGR_TITULO, AVGR_DT_INICIO, AVGR_DT_FINAL, AVGR_GRUPOACESSO, AVGR_AVISO, AVGR_status, AVGR_ANEXO
FROM AvisosGrupos 
WHERE (AVGR_DT_INICIO<=#auxdt# AND AVGR_DT_FINAL>=#auxdt# AND AVGR_status='A') AND 
(AVGR_GRUPOACESSO ='#qUsuario.Usu_GrupoAcesso#' OR AVGR_GRUPOACESSO='GERAL' OR 
(AVGR_GRUPOACESSO='GESTORINSPETOR' AND ('#qUsuario.Usu_GrupoAcesso#'='GESTORES' Or '#qUsuario.Usu_GrupoAcesso#'='INSPETORES'))
OR (AVGR_GRUPOACESSO='GESTORINSPETORANALISTA' AND ('#qUsuario.Usu_GrupoAcesso#'='GESTORES' Or '#qUsuario.Usu_GrupoAcesso#'='INSPETORES' Or '#qUsuario.Usu_GrupoAcesso#'='ANALISTAS')))
ORDER BY AVGR_ANO, AVGR_ID, AVGR_GRUPOACESSO, AVGR_DT_INICIO
</cfquery>

<cfset comReanalise = 0>
<cfif '#trim(qUsuario.Usu_GrupoAcesso)#' eq 'inspetores'> 
	<cfquery name="qComItensEmReanalise" datasource="#dsn_inspecao#">
		SELECT RIP_Recomendacao FROM Resultado_Inspecao
		INNER JOIN Inspetor_Inspecao ON IPT_NumInspecao = RIP_NumInspecao
		WHERE  IPT_MatricInspetor = '#qUsuario.Usu_Matricula#' and RIP_Recomendacao = 'S'
	</cfquery>
    <cfset comReanalise = '#qComItensEmReanalise.recordcount#'>
</cfif>	

<cfquery name="rsDia" datasource="#dsn_inspecao#">
  SELECT MSG_Realizado, MSG_Status FROM Mensagem WHERE MSG_Codigo = 1
</cfquery>

<cfif rsDia.MSG_Status is 'A'>
	 <cflocation url="SNCI_MENSAGEM.cfm?form.motivo=Sr(a) USUARIO(a), AGUARDE! EM POUCOS MINUTOS SERÁ LIBERADO O ACESSO, SNCI EM MANUTENCAO.">
</cfif>

<cfset auxdt = dateformat(now(),"YYYYMMDD")>
<cfset vDiaSem = DayOfWeek(auxdt)>
<cfset auxsite =  cgi.server_name>
<!--- <cfoutput>#auxsite#</cfoutput> --->
<cfif (rsDia.MSG_Realizado neq auxdt)>
   <cflocation url="Mensagens.cfm"> 
</cfif>

<!DOCTYPE html>
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">


<link href="CSS.css" rel="stylesheet" type="text/css">



</head>

<!--- Listas de permissões --->
		<cfquery name="qLista_Unid_Oper" datasource="#dsn_inspecao#">
			SELECT Usu_Login FROM usuarios WHERE RTrim(Usu_GrupoAcesso) = 'UNIDADES';
		</cfquery>
		<cfset Lista_Unid_Oper = UCase(ValueList(qLista_Unid_Oper.Usu_Login))>

		<cfquery name="qLista_Gestores" datasource="#dsn_inspecao#">
			SELECT Usu_Login FROM usuarios WHERE RTrim(Usu_GrupoAcesso)= 'GESTORES';
		</cfquery>
		<cfset Lista_Gestores = UCase(ValueList(qLista_Gestores.Usu_Login))>

		<cfquery name="qLista_Inspetores" datasource="#dsn_inspecao#">
			SELECT Usu_Login FROM usuarios WHERE RTrim(Usu_GrupoAcesso) = 'INSPETORES';
		</cfquery>
		<cfset Lista_Inspetores = UCase(ValueList(qLista_Inspetores.Usu_Login))>

		<cfquery name="qLista_Desenvolvedores" datasource="#dsn_inspecao#">
			SELECT Usu_Login FROM usuarios WHERE RTrim(Usu_GrupoAcesso) = 'DESENVOLVEDORES';
		</cfquery>
		<cfset Lista_Desenvolvedores = UCase(ValueList(qLista_Desenvolvedores.Usu_Login))>

		<cfquery name="qLista_Reop" datasource="#dsn_inspecao#">
			SELECT Usu_Login FROM usuarios WHERE RTrim(Usu_GrupoAcesso) = 'ORGAOSUBORDINADOR';
		</cfquery>
		<cfset Lista_Reop = UCase(ValueList(qLista_Reop.Usu_Login))>

		<cfquery name="qLista_Gerentes" datasource="#dsn_inspecao#">
			SELECT Usu_Login FROM usuarios WHERE RTrim(Usu_GrupoAcesso) = 'GERENTES';
		</cfquery>
		<cfset Lista_Gerentes = UCase(ValueList(qLista_Gerentes.Usu_Login))>

		<cfquery name="qLista_SubordinadorRegional" datasource="#dsn_inspecao#">
			SELECT Usu_Login FROM usuarios WHERE RTrim(Usu_GrupoAcesso) = 'SUBORDINADORREGIONAL';
		</cfquery>
		<cfset Lista_SubordinadorRegional = UCase(ValueList(qLista_SubordinadorRegional.Usu_Login))>

		<cfquery name="qLista_Superintendente" datasource="#dsn_inspecao#">
			SELECT Usu_Login FROM usuarios WHERE RTrim(Usu_GrupoAcesso) = 'SUPERINTENDENTE';
		</cfquery>
		<cfset Lista_Superintendente = UCase(ValueList(qLista_Superintendente.Usu_Login))>

		<cfquery name="qLista_Departamento" datasource="#dsn_inspecao#">
			SELECT Usu_Login FROM usuarios WHERE RTrim(Usu_GrupoAcesso) = 'DEPARTAMENTO';
		</cfquery>
		<cfset Lista_Departamento = UCase(ValueList(qLista_Departamento.Usu_Login))>
		
		<cfquery name="qLista_Governa" datasource="#dsn_inspecao#">
			SELECT Usu_Login FROM usuarios WHERE RTrim(Usu_GrupoAcesso) = 'GOVERNANCA';
		</cfquery>
		<cfset Lista_Governanca = UCase(ValueList(qLista_Governa.Usu_Login))>
		
		<cfquery name="qLista_Dcint" datasource="#dsn_inspecao#">
			SELECT Usu_Login FROM usuarios WHERE RTrim(Usu_GrupoAcesso) = 'GESTORMASTER';
		</cfquery>
		<cfset Lista_Dcint = UCase(ValueList(qLista_Dcint.Usu_Login))>
		
		 <cfquery name="qLista_Coordenador" datasource="#dsn_inspecao#">
			SELECT Usu_Login FROM usuarios WHERE RTrim(Usu_GrupoAcesso) = 'COORDENADOR';
		</cfquery>
		<cfset Lista_Coordenador = UCase(ValueList(qLista_Coordenador.Usu_Login))>	 	
		
		 <cfquery name="qLista_Analistas" datasource="#dsn_inspecao#">
			SELECT Usu_Login FROM usuarios WHERE RTrim(Usu_GrupoAcesso) = 'ANALISTAS';
		</cfquery>
		<cfset Lista_Analistas = UCase(ValueList(qLista_Analistas.Usu_Login))>	 

		<cfset Session.vPermissao = False>
		<cfset Session.vGerencia = ''>
		<cfset Session.vReop = ''>
		<cfset Session.vSubordinadorRegional = ''>


<!--- <body onLoad="abrirPopup('Avisos_Grupos.cfm?rotina=S',900,700);"> --->
 <body onLoad="pesquisa(); if ('<cfoutput>#rsAviso.recordcount#</cfoutput>' > 0) {abrirPopup('Avisos_Grupos.cfm?rotina=S',900,700)};"> 
	<td align="center"><cfinclude template="cabecalho.cfm"></td>
	<style>
		#div1{
			width:100%;
			max-height:90%;
			align-items: center;
		}

		#div2{
		align-items: center;
		margin-left:5%;
		margin-top:5%;
		}

		.icones{
			float: left;
			margin-top:3%;
			margin-left:3%;
			
		}
		
		
	</style>
	<a class="titulos" style="color:#fff;position:absolute;z-index: 10000;top:90px;right:15px">Versão: 2.3.1</a>	
<div id="div1" align="center" name ="div1" >

<div id="div2" align="center" name ="div2">
<!--- 10/11/2022 --->
	<cfif ListContains(ListQualify(Lista_Desenvolvedores,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) or ListContains(ListQualify(Lista_Inspetores,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) or ListContains(ListQualify(Lista_Gestores,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) or ListContains(ListQualify(Lista_Unid_Oper,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) Or ListContains(ListQualify(Lista_Reop,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) or ListContains(ListQualify(Lista_Gerentes,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) or ListContains(ListQualify(Lista_SubordinadorRegional,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) or ListContains(ListQualify(Lista_Superintendente,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) or ListContains(ListQualify(Lista_Departamento,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) Or ListContains(ListQualify(Lista_Analistas,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>

	    <div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('Avisosgrupos_botao.cfm?botaosn=S', 'SINS','toolbar=no,location=no,directories=no,status=yes,menubar=no,scrollbars=yes,resizable=yes,fullscreen=no')" src="icones/avisos.png" width="200" height="90" border="0" /></a></div>

		<cfset Session.vPermissao = True>
	</cfif>  
	
	<cfif ListContains(ListQualify(Lista_Inspetores,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) or ListContains(ListQualify(Lista_Desenvolvedores,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) >
		
		<div class="icones" width="10%" colspan="2" align="center"><a href="#">
		
		<img onClick="window.open('itens_inspetores_avaliacao.cfm', 'SINS','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,fullscreen=no')"  src="icones/AvaliacaoItens.jpg" width="200" height="90" border="0" /></a></div> 
		<cfset Session.vPermissao = True>
	</cfif>

	<cfif ListContains(ListQualify(Lista_Gestores,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) Or ListContains(ListQualify(Lista_Desenvolvedores,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>

		<div class="icones" width="10%" colspan="2" align="center"><a href="#"><img	onClick="abrirPopup('cadastro_inspecao.cfm',700,400)" src="icones/CadastroInspecao.jpg" width="200" height="90" border="0" /></a></div>

		<cfset Session.vPermissao=True>
    </cfif>
	
	<cfif ListContains(ListQualify(Lista_Inspetores,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) Or ListContains(ListQualify(Lista_Desenvolvedores,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>

	    <div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('itens_inspetores_controle_respostas_ref.cfm', 'SINS','toolbar=no,location=no,directories=no,status=yes,menubar=no,scrollbars=yes,resizable=yes,fullscreen=no')" src="icones/ControleRespostas.jpg" width="200" height="90" border="0" /></a></div>

		<cfset Session.vPermissao = True>
	</cfif>
	<cfif ListContains(ListQualify(Lista_Unid_Oper,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) Or ListContains(ListQualify(Lista_Reop,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) or ListContains(ListQualify(Lista_Gerentes,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) or ListContains(ListQualify(Lista_SubordinadorRegional,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) or ListContains(ListQualify(Lista_Superintendente,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) or ListContains(ListQualify(Lista_Departamento,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>
        <div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('consultar_permissao_usuarios.cfm', 'SINS','toolbar=no,location=no,directories=no,status=yes,menubar=no,scrollbars=yes,resizable=yes,fullscreen=no')" src="icones/ConsultaUsuarios.jpg" width="200" height="90" border="0" /></a></div>

	  	<cfset Session.vPermissao = True>
	</cfif>
	

	<cfif Left(cgi.REMOTE_USER,Len(Login_Agencia)) eq Login_Agencia Or Left(cgi.REMOTE_USER,Len(Login_CDD)) eq Login_CDD Or ListContains(ListQualify(Lista_Unid_Oper,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) Or ListContains(ListQualify(Lista_Desenvolvedores,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) Or ListContains(ListQualify(Lista_Coordenador,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) Or ListContains(ListQualify(Lista_Gestores,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) Or ListContains(ListQualify(Lista_Inspetores,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) Or ListContains(ListQualify(Lista_Dcint,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) Or ListContains(ListQualify(Lista_Analistas,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>

        <div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('itens_unidades_controle_respostas_ref.cfm', 'SINS','toolbar=no,location=no,directories=no,status=yes,menubar=no,scrollbars=yes,resizable=yes,fullscreen=no')" src="icones/RelatorioUnidade.jpg" width="200" height="90" border="0" /></a></div>

	  	<cfset Session.vPermissao = True>
	</cfif>
	
	<cfif Left(cgi.REMOTE_USER,Len(Login_Agencia)) eq Login_Agencia Or Left(cgi.REMOTE_USER,Len(Login_CDD)) eq Login_CDD Or ListContains(ListQualify(Lista_Unid_Oper,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) Or ListContains(ListQualify(Lista_Coordenador,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>
		<div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('abrir_pdf_act.cfm?arquivo=\\\\sac0424\\SISTEMAS\\SNCI\\GUIAS\\GUIA_UNIDADE.PDF','_blank')" src="icones/GuiaUnidade.png" width="200" height="90" border="0" /></a></div>
		<cfset Session.vPermissao = True>
	</cfif>

	<cfif ListContains(ListQualify(Lista_Inspetores,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) Or ListContains(ListQualify(Lista_Desenvolvedores,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>

	    <div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('itens_controle_pontosbaixados_ref.cfm', 'SINS','toolbar=no,location=no,directories=no,status=yes,menubar=no,scrollbars=yes,resizable=yes,fullscreen=no')" src="icones/ConsultaPontoBaixados.jpg" width="200" height="90" border="0" /></a></div>

		<cfset Session.vPermissao = True>
	</cfif>
	
	<cfif ListContains(ListQualify(Lista_Inspetores,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) Or ListContains(ListQualify(Lista_Desenvolvedores,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) Or ListContains(ListQualify(Lista_Coordenador,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) Or ListContains(ListQualify(Lista_Gestores,"'",",","CHAR"),ucase(cgi.REMOTE_USER))  Or ListContains(ListQualify(Lista_Dcint,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) Or ListContains(ListQualify(Lista_Analistas,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>

	    <div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('papel_trabalho_ref.cfm', 'SINS','toolbar=no,location=no,directories=no,status=yes,menubar=no,scrollbars=yes,resizable=yes,fullscreen=no')" src="icones/PapeldeTrabalho.jpg" width="200" height="90" border="0" /></a></div>

		<cfset Session.vPermissao = True>
	</cfif>
	
	<cfif ListContains(ListQualify(Lista_Reop,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>

	    	<div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('itens_unidades_controle_respostas_reop_ref.cfm', 'SINS','toolbar=no,location=no,directories=no,status=yes,menubar=no,scrollbars=yes,resizable=yes,fullscreen=no')" src="icones/relatorioOrgaoSubordinador.jpg" width="200" height="90" border="0" /></a></div>

		  <cfset Session.vPermissao = True>
		   <cfquery name="rsPermissaoReop" datasource="#dsn_inspecao#">
		   SELECT Usu_Login, Usu_Lotacao, Usu_GrupoAcesso
		   FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#' and RTrim(Usu_GrupoAcesso) = 'ORGAOSUBORDINADOR'
		   ORDER BY Usu_Lotacao ASC
		  </cfquery>
	
		  <cfif rsPermissaoReop.recordcount is 1>
			 <cfset Session.vReop = rsPermissaoReop.Usu_Lotacao>
		  </cfif>
  </cfif>
	<cfif ListContains(ListQualify(Lista_Reop,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) Or ListContains(ListQualify(Lista_Desenvolvedores,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>
		<div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('abrir_pdf_act.cfm?arquivo=\\\\sac0424\\SISTEMAS\\SNCI\\GUIAS\\GUIA_ORGAO_SUBORDINADOR.PDF','_blank')" src="icones/GuiaOrgaoSubordinador.png" width="200" height="90" border="0" /></a></div>
		<cfset Session.vPermissao = True>
	</cfif>

	<cfif ListContains(ListQualify(Lista_Gerentes,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>

			<div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('itens_area_respostas_consulta_ref.cfm', 'SINS','toolbar=no,location=no,directories=no,status=yes,menubar=no,scrollbars=yes,resizable=yes,fullscreen=no')" src="icones/relatoriogerencias.jpg" width="200" height="90" border="0" /></a></div>
	
		<cfset Session.vPermissao = True>
		  <cfquery name="rsPermissao" datasource="#dsn_inspecao#">
			 SELECT Usu_Login, Usu_Lotacao, Usu_GrupoAcesso
			 FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#' and RTrim(Usu_GrupoAcesso) = 'GERENTES'
			 ORDER BY Usu_Lotacao ASC
		  </cfquery>
		   <cfif rsPermissao.recordcount is  1>
			  <cfset Session.vGerencia = rsPermissao.Usu_Lotacao>
		   </cfif>
	</cfif>
	
	<cfif ListContains(ListQualify(Lista_Gerentes,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) or ListContains(ListQualify(Lista_Desenvolvedores,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>
		<div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('abrir_pdf_act.cfm?arquivo=\\\\sac0424\\SISTEMAS\\SNCI\\GUIAS\\GUIA_AREA.PDF','_blank')" src="icones/GuiaArea.png" width="200" height="90" border="0" /></a></div>
		<cfset Session.vPermissao = True>
	</cfif>
	
	<cfif ListContains(ListQualify(Lista_SubordinadorRegional,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>
		<div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('abrir_pdf_act.cfm?arquivo=\\\\sac0424\\SISTEMAS\\SNCI\\GUIAS\\GUIA_SUBORDINADORREGIONAL.PDF','_blank')" src="icones/GuiaUnidade.png" width="200" height="90" border="0" /></a></div>
		<cfset Session.vPermissao = True>
	</cfif>

	<cfif ListContains(ListQualify(Lista_SubordinadorRegional,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>
			<div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('itens_subordinador_respostas_pendentes_regional_ref.cfm', 'SINS','toolbar=no,location=no,directories=no,status=yes,menubar=no,scrollbars=yes,resizable=yes,fullscreen=no')" src="icones/subordinacaoregional.jpg" width="200" height="90" border="0" /></a></div>
	
		  <cfset Session.vPermissao = True>
		   <cfquery name="rsPermissaoSubordinadorRegional" datasource="#dsn_inspecao#">
		   SELECT Usu_Login, Usu_Lotacao, Usu_GrupoAcesso
		   FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#' and RTrim(Usu_GrupoAcesso) = 'SUBORDINADORREGIONAL'
		   ORDER BY Usu_Lotacao ASC
		  </cfquery>
	
		  <cfif rsPermissaoSubordinadorRegional.recordcount is 1>
			 <cfset Session.vSubordinadorRegional = rsPermissaoSubordinadorRegional.Usu_Lotacao>
		  </cfif>
  </cfif>

	 <cfif ListContains(ListQualify(Lista_Superintendente,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>

			<div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('itens_se_controle_respostas_ref.cfm', 'SINS','toolbar=no,location=no,directories=no,status=yes,menubar=no,scrollbars=yes,resizable=yes,fullscreen=no')" src="icones/CorporativoSE.jpg" width="200" height="90" border="0" /></a></div>
	
		<!---   <cfset Session.vPermissao = True> --->
		   <cfquery name="rsPermissaoSuperintendente" datasource="#dsn_inspecao#">
		   SELECT Usu_Login, Usu_Lotacao, Usu_GrupoAcesso
		   FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#' and RTrim(Usu_GrupoAcesso) = 'SUPERINTENDENTE'
		   ORDER BY Usu_Lotacao ASC
		  </cfquery>
	
		  <cfif rsPermissaoSuperintendente.recordcount is 1>
			 <cfset Session.vSuperintendente = rsPermissaoSuperintendente.Usu_Lotacao>
		  </cfif>
		  <cfset Session.vPermissao = True>
	 </cfif>
	  
	 <cfif ListContains(ListQualify(Lista_Superintendente,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) or ListContains(ListQualify(Lista_Gerentes,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) or ListContains(ListQualify(Lista_Reop,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) or ListContains(ListQualify(Lista_SubordinadorRegional,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>
			<div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('se_indicadores_ref.cfm', 'SINS','toolbar=no,location=no,directories=no,status=yes,menubar=no,scrollbars=yes,resizable=yes,fullscreen=no')" src="icones/Consulta_Indicadores.png" width="200" height="90" border="0" /></a></div>
			<cfset Session.vPermissao = True>
	 </cfif>	 
	 <cfif ListContains(ListQualify(Lista_Gestores,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) OR ListContains(ListQualify(Lista_Desenvolvedores,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>
		<div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('abrir_pdf_act.cfm?arquivo=\\\\sac0424\\SISTEMAS\\SNCI\\GUIAS\\GUIA_GESTORES.PDF','_blank')" src="icones/ManualGestores.png" width="200" height="90" border="0" /></a></div>
		<cfset Session.vPermissao = True>
	</cfif>
	 <cfif ListContains(ListQualify(Lista_Gestores,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) OR ListContains(ListQualify(Lista_Inspetores,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) OR ListContains(ListQualify(Lista_Desenvolvedores,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>
		<div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('abrir_pdf_act.cfm?arquivo=\\\\sac0424\\SISTEMAS\\SNCI\\GUIAS\\Guia_SCOI.pdf','_blank')" src="icones/GuiaOrientacao.png" width="200" height="90" border="0" /></a></div>
		<cfset Session.vPermissao = True>
	</cfif>
	
    <cfif ListContains(ListQualify(Lista_Gestores,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) OR ListContains(ListQualify(Lista_Desenvolvedores,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) OR ListContains(ListQualify(Lista_Analistas,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>
		<div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('abrir_pdf_act.cfm?arquivo=\\\\sac0424\\SISTEMAS\\SNCI\\GUIAS\\Guia_SCIA.PDF','_blank')" src="icones/GuiaInspetores.png" width="200" height="90" border="0" /></a></div>
		<cfset Session.vPermissao = True>
	</cfif>

	  <cfif ListContains(ListQualify(Lista_Departamento,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>

	    <div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('itens_consulta_gestores_pendentes_ref.cfm', 'SINS','toolbar=no,location=no,directories=no,status=yes,menubar=no,scrollbars=yes,resizable=yes,fullscreen=no')" src="icones/CorporativoCS.jpg" width="200" height="90" border="0" /></a></div>

	   <cfset Session.vPermissao = True>
	   <cfquery name="rsPermissaoDepartamento" datasource="#dsn_inspecao#">
	   SELECT Usu_Login, Usu_Lotacao, Usu_GrupoAcesso
	   FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#' and RTrim(Usu_GrupoAcesso) = 'DEPARTAMENTO'
	   ORDER BY Usu_Lotacao ASC
	  </cfquery>

	  <cfif rsPermissaoDepartamento.recordcount is 1>
	     <cfset Session.vDepartamento = rsPermissaoDepartamento.Usu_Lotacao>
	  </cfif>
	 </cfif>


	<cfif ListContains(ListQualify(Lista_Desenvolvedores,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) Or ListContains(ListQualify(Lista_Coordenador,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) Or ListContains(ListQualify(Lista_Gestores,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) Or ListContains(ListQualify(Lista_Dcint,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>
	    <div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('index.cfm', 'SINS','toolbar=no,location=no,directories=no,status=yes,menubar=no,scrollbars=yes,resizable=yes,fullscreen=no')" src="icones/gerenciamento_de_inspecoes.jpg" width="200" height="90" border="0" /></a></div>	  </tr>
	  <cfset Session.vPermissao = True>
    </cfif>
	<cfif ListContains(ListQualify(Lista_Governanca,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>
	    <div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('index.cfm', 'SINS','toolbar=no,location=no,directories=no,status=yes,menubar=no,scrollbars=yes,resizable=yes,fullscreen=no')" src="icones/ConsultaAvaliacao.png" width="200" height="90" border="0" /></a></div>	  </tr>
	  <cfset Session.vPermissao = True>
    </cfif>	

 	<cfif ListContains(ListQualify(Lista_Dcint,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) Or ListContains(ListQualify(Lista_Analistas,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) Or ListContains(ListQualify(Lista_Gestores,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) or ListContains(ListQualify(Lista_Reop,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) or ListContains(ListQualify(Lista_Gerentes,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) or ListContains(ListQualify(Lista_SubordinadorRegional,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) or ListContains(ListQualify(Lista_Superintendente,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) Or ListContains(ListQualify(Lista_Governanca,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>

	    <div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('Rel_indicadoresglobal_ref.cfm', 'SINS','toolbar=no,location=no,directories=no,status=yes,menubar=no,scrollbars=yes,resizable=yes,fullscreen=no')" src="icones/Metas.png" width="200" height="90" border="0" /></a></div>

		<cfset Session.vPermissao = True>
	</cfif> 
 	<!--- <cfif ListContains(ListQualify(Lista_Dcint,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) or ListContains(ListQualify(Lista_Gestores,"'",",","CHAR"),ucase(cgi.REMOTE_USER))> --->
	<cfif ListContains(ListQualify(Lista_Dcint,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>

	    <div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('Pacin_Unidades_Avaliacao_ref.cfm', 'SINS','toolbar=no,location=no,directories=no,status=yes,menubar=no,scrollbars=yes,resizable=yes,fullscreen=no')" src="icones/UnidadeAvaliacao.png" width="200" height="90" border="0" /></a></div>

		<cfset Session.vPermissao = True>
	</cfif> 	
	<cfif ListContains(ListQualify(Lista_Dcint,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>

	    <div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('cadastrogruposItens.cfm', 'SINS','toolbar=no,location=no,directories=no,status=yes,menubar=no,scrollbars=yes,resizable=yes,fullscreen=no')" src="icones/Cadastrogrupoitem.jpg" width="200" height="90" border="0" /></a></div>

		<cfset Session.vPermissao = True>
	</cfif>
	
	<cfif ListContains(ListQualify(Lista_Desenvolvedores,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) Or ListContains(ListQualify(Lista_Analistas,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>

        <div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('index.cfm', 'SINS','toolbar=no,location=no,directories=no,status=yes,menubar=no,scrollbars=yes,resizable=yes,fullscreen=no')" src="icones/GA_analistas.jpg" width="200" height="90" border="0" /></a></div>

	  	<cfset Session.vPermissao = True>
	</cfif>
<cfif ListContains(ListQualify(Lista_Inspetores,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) or ListContains(ListQualify(Lista_Desenvolvedores,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) or ListContains(ListQualify(Lista_Gestores,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) Or ListContains(ListQualify(Lista_Analistas,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>
		
		<div class="icones" width="10%" colspan="2" align="center"><a href="#">
		
		<img onClick="window.open('Rel_itensverificacao_ref.cfm', 'SINS','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,fullscreen=no')"  src="icones/Listarchecklist.png" width="200" height="90" border="0" /></a></div> 
		<cfset Session.vPermissao = True>
</cfif>
	<cfif ListContains(ListQualify(Lista_Dcint,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>
	    <div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('https://app.powerbi.com/reportEmbed?reportId=2c84bd6e-8587-4c00-a8a0-f3f36cc75d75&amp;autoAuth=true&amp;ctid=349047e4-8aa4-4867-b4f7-bc3cb08bbb60&amp;config=eyJjbHVzdGVyVXJsIjoiaHR0cHM6Ly93YWJpLW5vcnRoLWV1cm9wZS1oLXByaW1hcnktcmVkaXJlY3QuYW5hbHlzaXMud2luZG93cy5uZXQvIn0%3D', 'SINS','toolbar=no,location=no,directories=no,status=yes,menubar=no,scrollbars=yes,resizable=yes,fullscreen=no')" src="icones/dashboardMonitoramento.png" width="200" height="90" border="0" /></a></div>	  </tr>
	  <cfset Session.vPermissao = True>
    </cfif>
	
<!--- <cfif ListContains(ListQualify(Lista_Dcint,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>
	    <div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('Itens_ajustaremlote.cfm', 'SINS','toolbar=no,location=no,directories=no,status=yes,menubar=no,scrollbars=yes,resizable=yes,fullscreen=no')" src="icones/Proc_lote.png" width="200" height="90" border="0" /></a></div>	  </tr>
	  <cfset Session.vPermissao = True>
    </cfif>	 --->

 <cfif ListContains(ListQualify(Lista_Inspetores,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) OR ListContains(ListQualify(Lista_Desenvolvedores,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>
		<div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('abrir_pdf_act.cfm?arquivo=\\\\sac0424\\SISTEMAS\\SNCI\\GUIAS\\GUIA_INSPETORES.PDF','_blank')" src="icones/GuiaUnidade.png" width="200" height="90" border="0" /></a></div>
		<cfset Session.vPermissao = True>
	</cfif>
 <cfif ListContains(ListQualify(Lista_Analistas,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>
		<div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('abrir_pdf_act.cfm?arquivo=\\\\sac0424\\SISTEMAS\\SNCI\\GUIAS\\GUIA_ANALISTAS.PDF','_blank')" src="icones/GuiaUnidade.png" width="200" height="90" border="0" /></a></div>
		<cfset Session.vPermissao = True>
	</cfif>	
	 <cfif ListContains(ListQualify(Lista_Superintendente,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>
		<div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('abrir_pdf_act.cfm?arquivo=\\\\sac0424\\SISTEMAS\\SNCI\\GUIAS\\GUIA_SUPERINTENDENTE.PDF','_blank')" src="icones/GuiaUnidade.png" width="200" height="90" border="0" /></a></div>
		<cfset Session.vPermissao = True>
	</cfif>	
	 <cfif ListContains(ListQualify(Lista_Departamento,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>
		<div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('abrir_pdf_act.cfm?arquivo=\\\\sac0424\\SISTEMAS\\SNCI\\GUIAS\\GUIA SNCI_DEPARTAMENTO.PDF','_blank')" src="icones/GuiaUnidade.png" width="200" height="90" border="0" /></a></div>
		<cfset Session.vPermissao = True>
	</cfif>	
	 <cfif ListContains(ListQualify(Lista_Dcint,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>
		<div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('abrir_pdf_act.cfm?arquivo=\\\\sac0424\\SISTEMAS\\SNCI\\GUIAS\\GUIA SNCI_GESTORMASTER.PDF','_blank')" src="icones/GuiaUnidade.png" width="200" height="90" border="0" /></a></div>
		<cfset Session.vPermissao = True>
	</cfif>	
	

<!--- 	<cfif ListContains(ListQualify(Lista_Inspetores,"'",",","CHAR"),ucase(cgi.REMOTE_USER))>
	    <div class="icones" width="10%" colspan="2" align="center"><a href="#"><img onClick="window.open('Itens_Analise_Manifestacao_ref.cfm', 'SINS','toolbar=no,location=no,directories=no,status=yes,menubar=no,scrollbars=yes,resizable=yes,fullscreen=no')" src="icones/AnaliseManifestacao.png" width="200" height="90" border="0" /></a></div>	  </tr>
	  <cfset Session.vPermissao = True>
    </cfif>	 --->
	<cfif not Session.vPermissao>
	    <div class="icones" colspan="2" align="center" class="red_titulo style5">Caro colaborador, você não tem permissão para acessar essa página. Procure o administrador do sistema no Departamento de Controle Interno - DCINT.</div>
    </cfif>

	<cfquery name="qData" datasource="#dsn_inspecao#">
	  SELECT Pos_DtPrev_Solucao
      FROM ParecerUnidade
      WHERE (Pos_DtPrev_Solucao <= convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')) AND Pos_Situacao_Resp ='8'
	</cfquery>

    

</div>

</div>
	<cfif ListContains(ListQualify(Lista_Inspetores,"'",",","CHAR"),ucase(cgi.REMOTE_USER)) and '#comReanalise#' neq 0>
		<div align="center" >
			<div align="center" style="position:RELATIVE; top:20px;left:0px;background:red;color:#fff;width:540px;padding:3px;font-family:Verdana, Arial, Helvetica, sans-serif">						
				<div style="float: left;">
			    	<img id="imgAtencao" name="imgAtencao"src="figuras/atencao.png" width="50px"  border="0" ></img>
				</div>
				<div style="float: left;">
			    	<span style="font-size:10px;position:relative;top:11px"><strong>Sr. Inspetor! Existem Avaliações de Controle com itens pendentes de REANÁLISE. <br>Favor priorizar os ajustes solicitados!</strong></span> 							
				</div>							
			</div>
		</div>
	</cfif>
<!--- rotina para aviso  às unidades ref. pesquisa de Opinião --->
<cfset pesquisa = ''>
<cfif ucase(trim(qUsuario.Usu_GrupoAcesso)) eq 'UNIDADES'>
<cfoutput>
	<cfquery name="rsAviso1" datasource="#dsn_inspecao#">
		SELECT Pes_Inspecao, Und_Descricao, INP_Responsavel, Und_Email
		FROM (Pesquisa_Pos_Avaliacao INNER JOIN Inspecao ON Pes_Inspecao = INP_NumInspecao) INNER JOIN Unidades ON INP_Unidade = Und_Codigo
		WHERE (Pes_GestorNome is Null) and (DATEDIFF(d,GETDATE(),Pes_dtinicio) <= 10) and Pes_Ctrl_AvisoB = 0 and INP_Unidade = '#qUsuario.Usu_Lotacao#'
		order by Pes_Inspecao
	</cfquery>

	<cfquery name="rsAviso2" datasource="#dsn_inspecao#">
		SELECT Pes_Inspecao, Und_Descricao, INP_Responsavel, Und_Email
		FROM (Pesquisa_Pos_Avaliacao INNER JOIN Inspecao ON Pes_Inspecao = INP_NumInspecao) INNER JOIN Unidades ON INP_Unidade = Und_Codigo 
		WHERE (Pes_GestorNome is Null) and (DATEDIFF(d,GETDATE(),Pes_dtinicio) > 10) and (DATEDIFF(d,GETDATE(),Pes_dtinicio) <= 20) and Pes_Ctrl_AvisoB = 1 and INP_Unidade = '#qUsuario.Usu_Lotacao#'
		order by Pes_Inspecao
	</cfquery>
	
	<cfquery name="rsAviso3" datasource="#dsn_inspecao#">
		SELECT Pes_Inspecao, Und_Descricao, INP_Responsavel, Und_Email
		FROM (Pesquisa_Pos_Avaliacao INNER JOIN Inspecao ON Pes_Inspecao = INP_NumInspecao) INNER JOIN Unidades ON INP_Unidade = Und_Codigo 
		WHERE (Pes_GestorNome is Null) and (DATEDIFF(d,GETDATE(),Pes_dtinicio) > 20) and (DATEDIFF(d,GETDATE(),Pes_dtinicio) <= 31) and Pes_Ctrl_AvisoB = 2 and INP_Unidade = '#qUsuario.Usu_Lotacao#'
		order by Pes_Inspecao
	</cfquery>	

	<cfif rsAviso1.recordcount gt 0>
	 	<cfset pesquisa = rsAviso1.Pes_Inspecao>
		<cfquery datasource="#dsn_inspecao#">
			UPDATE Pesquisa_Pos_Avaliacao SET Pes_Ctrl_AvisoB = 1, Pes_dtultatu = CONVERT(char, GETDATE(), 120)
			WHERE Pes_Inspecao ='#pesquisa#'	
		</cfquery>	
	<cfelseif rsAviso2.recordcount gt 0>
	 	<cfset pesquisa = rsAviso2.Pes_Inspecao>
		<cfquery datasource="#dsn_inspecao#">
			UPDATE Pesquisa_Pos_Avaliacao SET Pes_Ctrl_AvisoB = 2, Pes_dtultatu = CONVERT(char, GETDATE(), 120)
			WHERE Pes_Inspecao ='#pesquisa#'	
		</cfquery>			
	<cfelseif rsAviso3.recordcount gt 0>
	 	<cfset pesquisa = rsAviso3.Pes_Inspecao>
		<cfquery datasource="#dsn_inspecao#">
			UPDATE Pesquisa_Pos_Avaliacao SET Pes_Ctrl_AvisoB = 3, Pes_dtultatu = CONVERT(char, GETDATE(), 120)
			WHERE Pes_Inspecao ='#pesquisa#'	
		</cfquery>			
	</cfif>
	</cfoutput>
</cfif>	

<!---  --->
<form name="formx" action="Pesquisa.cfm" method="get" target="_parent">
	<input name="ninsp" type="hidden" value="<cfoutput>#pesquisa#</cfoutput>">
</form>

</body>
</html>
