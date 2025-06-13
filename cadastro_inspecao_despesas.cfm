<cfprocessingdirective pageEncoding ="utf-8">
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	<!---
	<cfinclude template="permissao_negada.htm">
	<cfabort>
	--->
</cfif>      
<cfparam name="url.numInspecao" default="00000000">
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select * from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<cfset grpacesso = ucase(trim(qAcesso.Usu_GrupoAcesso))>
<!---
<cfif #grpacesso# neq "GESTORES">
  <h1>Página exclusiva para o grupo de acesso: GESTORES!</h1>
	  <cfabort> 
</cfif>  
--->

	<cfif isDefined("form.acao") And (#form.acao# eq 'salvar')>
		<cfset url.numInspecao = #form.inspecao#>
			<cfset inpvalorprevisto = Replace(form.inpvalorprevisto,'.','','All')>
			<cfset inpvalorprevisto = Replace(inpvalorprevisto,',','.','All')>
			<cfset inpadinoturno = Replace(form.inpadinoturno,'.','','All')>
			<cfset inpadinoturno = Replace(inpadinoturno,',','.','All')>
			<cfset inpdeslocamento = Replace(form.inpdeslocamento,'.','','All')>
			<cfset inpdeslocamento = Replace(inpdeslocamento,',','.','All')>
			<cfset inpdiarias = Replace(form.inpdiarias,'.','','All')>
			<cfset inpdiarias = Replace(inpdiarias,',','.','All')>
			<cfset inppassagemarea = Replace(form.inppassagemarea,'.','','All')>
			<cfset inppassagemarea = Replace(inppassagemarea,',','.','All')>
			<cfset inpreembveicproprio = Replace(form.inpreembveicproprio,'.','','All')>
			<cfset inpreembveicproprio = Replace(inpreembveicproprio,',','.','All')>
			<cfset inprepousoremunerado = Replace(form.inprepousoremunerado,'.','','All')>
			<cfset inprepousoremunerado = Replace(inprepousoremunerado,',','.','All')>
			<cfset inpressarcirempregado = Replace(form.inpressarcirempregado,'.','','All')>
			<cfset inpressarcirempregado = Replace(inpressarcirempregado,',','.','All')>
			<cfset inpoutros = Replace(form.inpoutros,'.','','All')>
			<cfset inpoutros = Replace(inpoutros,',','.','All')>
			<cfquery datasource="#dsn_inspecao#">
				UPDATE Inspecao 
					SET 
					INP_ValorPrevisto          = #inpvalorprevisto#
					, INP_AdiNoturno           = #inpadinoturno#
					, INP_Deslocamento         = #inpdeslocamento#
					, INP_Diarias              = #inpdiarias#
					, INP_PassagemArea         = #inppassagemarea#
					, INP_ReembVeicProprio     = #inpreembveicproprio#
					, INP_RepousoRemunerado    = #inprepousoremunerado#
					, INP_RessarcirEmpregado   = #inpressarcirempregado#
					, INP_Outros               = #inpoutros#
					, INP_DTConcluir_Despesas  = CONVERT(char, GETDATE(), 120)
					, INP_LoginGestor_Despesas = '#CGI.REMOTE_USER#'
					WHERE INP_NumInspecao = '#url.numInspecao#'
			</cfquery>
			<script>
				alert('Gestor(a), Recursos alocados salvos com sucesso!')
			</script>
	</cfif>
<cfquery name="rsResult" datasource="#dsn_inspecao#">
	SELECT 
	  INP_Unidade
	, Und_Descricao
	, INP_NumInspecao
	, INP_Responsavel
	, INP_HrsPreInspecao
	, INP_DtInicDeslocamento
	, INP_DtFimDeslocamento
	, INP_HrsDeslocamento
	, INP_DtInicInspecao
	, INP_DtFimInspecao
	, INP_HrsInspecao
	, INP_DtEncerramento
	, INP_Coordenador
	, INP_ValorPrevisto
	, INP_AdiNoturno
	, INP_Deslocamento
	, INP_Diarias
	, INP_PassagemArea
	, INP_ReembVeicProprio
	, INP_RepousoRemunerado
	, INP_RessarcirEmpregado
	, INP_Outros
	, INP_DTConcluir_Despesas
	, INP_LoginGestor_Despesas
	, IPT_MatricInspetor
	, trim(Fun_Nome) as funome
	, Usu_Apelido
	FROM 
	((Inspecao 
	INNER JOIN Unidades ON INP_Unidade = Und_Codigo) 
	INNER JOIN Inspetor_Inspecao ON (INP_NumInspecao = IPT_NumInspecao) AND (INP_Unidade = IPT_CodUnidade)) 
	INNER JOIN Funcionarios ON IPT_MatricInspetor = Fun_Matric
	LEFT JOIN Usuarios ON INP_LoginGestor_Despesas = Usu_Login
 	WHERE INP_NumInspecao='#url.numInspecao#' 
</cfquery>

<!---
<cfif isDefined("url.numInspecao") And (#url.numInspecao# neq '')>

<cfelse>

</cfif>
--->
<!--- Área de conteúdo   --->


<cfif isDefined("url.numInspecao") And (#url.numInspecao# neq '')>

</cfif>

<!doctype html>
<html lang="pt-br">
<head>
<meta charset="utf-8">
<title>SISTEMA NACIONAL DE CONTROLE INTERNO - SNCI</title>
<meta name="description" content="Teste ">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<script type="text/javascript" src="ckeditor/ckeditor.js"></script>
<link rel="stylesheet" href="public/bootstrap/bootstrap.min.css">
<!--[if lt IE 9]>
    <script src="js/html5shiv.js"></script>
	<script src="js/css3-mediaqueries.js"></script>
<![endif]-->
<style>
/* http://meyerweb.com/eric/tools/css/reset/ 
   v2.0 | 20110126
   License: none (public domain)
   MODIFICADO
*/
html, body, div, span, h1, h2, h3, h4, h5, h6, p, blockquote, 
a, ul, li, article, aside, footer, header, nav, section {
	margin: 0;
	padding: 0;
	border: 0;
	font-size: 100%;
	font: inherit;
	vertical-align: baseline;
}
/* HTML5 display-role reset for older browsers */
article, aside, footer, header, nav, section {
	display: block;
}
ul {
	list-style: none;
}
/* Fim Eric Meyer reset */
/* utilidades */
*, *:before, *:after {
  -moz-box-sizing: border-box; 
  -webkit-box-sizing: border-box;
   box-sizing: border-box;
}
.cf:before,
.cf:after {
    content: " "; 
    display: table;
}
.cf:after {
    clear: both;
}
.cf {
    *zoom: 1;
}
/* Fim utilidades */
body {
	font: 100%/1.4 sans-serif;
}

h1, h2 {
	font-weight: bold;
}
h1 { font-size: 140%; }
h2 { font-size: 100%; }
p { margin: 0.6em 0; }
p:last-child { 
	margin-bottom:0; 
	padding-bottom: 0.6em
}
.topo { 
	background: #070ab2;
	color: #fff; 
	font-size: 70%;
	line-height: 2.5em;
	text-align: center;
	white-space: nowrap;
	overflow: hidden;
}
.principal { background: rgb(255, 255, 0);}
.principal header, .auxiliar h1 { text-align: center; color: #14169c;}
.bloco, .auxiliar article {
	border-bottom: 1px solid #171996;
	padding: 0.8em 0;
	}
.bloco h2 {
	font-weight: bold;
	font-size: 140%;
}
.bloco h3 {
	font-weight: bold;
	font-size: 130%;
}
h5 {
	font-weight: bold;
	font-size: 80%;
}
.auxiliar { background: #fff; }
.auxiliar p { margin-top: 0; }

.rodape { 
	background: #1417d6;
	color: #fff;
	text-align: center;
	}
a, a:active {
	text-decoration: none;
	color: blue;
}
a:hover {
	text-decoration: underline;
	color: #333;
}
/* navegação mobile */
.navegacao ul {
	margin:  0;
	padding: 0;
}
.navegacao li {
	list-style: none;
	font-size: 110%; 
	border-bottom: 1px solid #fff; 
}
.menu-icon {
	padding-top: .5em;
	font-size: 120%; 
	color: #fff; 
}
.navegacao a {
	display: block;
	padding: 0.25em 1em 0.25em 1em;
	text-decoration: none;
}
.navegacao li a {
	color: #fff;
}
.navegacao li a:hover, .navegacao li a:focus, .navegacao li a:active {
	color: #3e4095;
}
.navegacao {
	font: bold 90%/1.4 sans-serif; 
	background: #00a85a0b;
	height: 2.8em; 
/*	overflow: hidden;
		webkit-transition: height 2s;
		-moz-transition: height 2s; 
		-o-transition: height 2s; 
		-ms-transition: height 2s; 
		transition: height 2s;
		*/
}
.navegacao:hover, .navegacao:focus, .navegacao:active {
	/*
	height: 60em; 
		-webkit-transition: height 2s; 
		-moz-transition: height 2s; 
		-o-transition: height 2s; 
		-ms-transition: height 2s; 
		transition: height 2s;
	*/
}
/* Fim navegação mobile */
@media all and (min-width:30em) {
	body {	
		background-image: url(imagens/bg1000x80cap3.jpg);
		background-repeat: no-repeat;
		background-position: left top;
	}
	.topo { background: transparent; }
	.topo h1 { 
		color: #00a859; 
		font-size: 250%;
		margin: 0.6em 0;
		text-shadow: 3px 3px 2px #666;
	}
	.main-page { background: #00a859; }
	.principal {
		width: 75%;
		padding: 0.5em;
		float: right;
	}
	.auxiliar {
		width: 60%;
		float: right;
	}
	.navegacao {
		float:left;
		width: 30%;
		height: 46em;
	}
	.navegacao li:first-child { border-top: 1px solid #fff; }
	.menu-icon {
		text-indent: -1000em; 
		height: 0;	
		line-hight: 0;
	}
}
@media all and (min-width:62.5em) {
	body {	
		background-image: url(imagens/bg1200x1200cap3.jpg);
		background-size: cover;
	}
	.topo h1 { 
		font-size: 480%;
		margin: 0.8em 0;
	}
	.main-page {background: none;}
	.principal {
		width: 58%;
		float: left;
		background: transparent;
	}
	.principal header {
		background: #1114bc;
		color:#fff;
		margin-bottom: 0.3em;
	}		
	.bloco {
		padding: 0 .5em;
		background: rgba(255, 255, 0, 0.046);
	}
	.auxiliar {
		width: 20%;
		padding: 0 0.4em;
	}
	.navegacao {
		width: 21%;
	}
}

.box{
	margin-top: 0.3em;
	padding: 0.1em 0.1em;
	display: inline-block;
	/*definimos a largura do box*/
	width:90px;
	/* definimos a altura do box */
	height:37px;
	/* definimos a cor de fundo do box */
	background-color:#6494ed12;
	/* definimos o quão arredondado irá ficar nosso box */
	border-radius: 10px 20px;
	}

.btnsalvar{
	margin-top: 0.3em;
	padding: 0.2em;
	color: #fff;
	display: inline-block;
	width:190px;
	height:25px;
	background-color:#0c5adf;
	border-radius: 10px 20px;
	cursor: pointer;
	}	
.btnfechar{
	margin-top: 0.3em;
	padding: 0.2em;
	color: #fff;
	display: inline-block;
	width:170px;
	height:25px;
	background-color:#e30505f1;
	border-radius: 10px 20px;
	cursor: pointer;
	}	

table {

	border-radius: 5px;
	border: 1px solid black;

}
td, th, label {

	height: 30px;
	border: 1px solid #666;
	border-radius: 15px;

}

.lblbtn {
	padding: 0.25em 1em 0.25em 1em;
	background-color: #e6a50d;
	height: 20px;
	border: 1px solid #666;
	border-radius: 5px;
	font: bold 75%/1.4 sans-serif; 
	vertical-align: middle;
  	text-align: center;
}
label {
	padding: 0.25em 1em 0.25em 1em;
	background-color:#DCDCDC;
	height: 20px;
	border: 1px solid #666;
	border-radius: 10px;
	font: bold 75%/1.4 sans-serif; 
	vertical-align: middle;
  	text-align: center;
}

</style>
</head>
<body id="home">
<div class="tudo">
	<header class="topo">	
    	<cfinclude template="cabecalho.cfm">
	</header>
	<nav class="navegacao" aria-haspopup="true">
		<cfoutput>
			<table width="40%" align="center" class="table table-bordered table-hover">
				<tr>
					<td colspan="2" align="center"><div><label>Avaliação</label></div></td>
				</tr>
				<tr>
					<td colspan="2" align="center"><div><h5>#numInspecao#</h5></div></td>
				</tr>
				<tr>
					<td colspan="2" align="center"><div><label>Unidade</label></div></td>
				</tr>
				<tr>
					<td colspan="2" align="center"><div><h5>#rsResult.INP_Unidade# - #rsResult.Und_Descricao#</h5></div></td>
				</tr>
				<tr>
					<td colspan="2" align="center"><div><label>Responsável</label></div></td>
				</tr>
				<tr>
					<td colspan="2" align="center"><div><h5>#rsResult.INP_Responsavel#</h5></div></td>
				</tr>					
			</table>
		</cfoutput>
		<cfoutput>
			<header>
				<div id="datasaval"><label>Datas</label></div>
			</header>
			<div>				
				<table width="100%" align="center" class="table table-bordered table-hover">	
					<tr><td colspan="4"><h5>Deslocamento</h5></td></tr>			
					<tr>
						<td align="center">
							<small>Pré</small>
						</td>
						<td align="center">
							<small>Início</small>
						</td>
						<td align="center">
							<small>Final</small>
						</td>
						<td align="center">
							<small>Horas</small>
						</td>
					</tr>
					<tr>
						<td align="center">
							<small>#rsResult.INP_HrsPreInspecao#h</small>
						</td>
						<td align="center">
							<small>#dateformat(rsResult.INP_DtInicDeslocamento,"dd-mm-yyyy")#</small>
						</td>
						<td align="center">
							<small>#dateformat(rsResult.INP_DtFimDeslocamento,"dd-mm-yyyy")#</small>
						</td>
						<td align="center">
							<small>#rsResult.INP_HrsDeslocamento#h</small>
						</td>
					</tr>
					<tr><td colspan="4"><h5>Avaliação</h5></td></tr>
					<tr>
						<td align="center">
							<small>Início</small>
						</td>
						<td align="center">
							<small>Final</small>
						</td>
						<td align="center">
							<small>Horas</small>
						</td>
						<td align="center">
							<small>Encerramento</small>
						</td>
					</tr>
					<tr>
						<td align="center">
							<small>#dateformat(rsResult.INP_DtInicInspecao,"dd-mm-yyyy")#</small>
						</td>
						<td align="center">
							<small>#dateformat(rsResult.INP_DtFimInspecao,"dd-mm-yyyy")#</small>
						</td>
						<td align="center">
							<small>#rsResult.INP_HrsInspecao#h</small>
						</td>
						<td align="center">
							<small>#dateformat(rsResult.INP_DtEncerramento,"dd-mm-yyyy")#</small>
						</td>
					</tr>		
				</table>	
			</div>		
		</cfoutput>		
		<div><hr></div>
		<div id="avaliacao"><label>Inspetores</label>
			<div>
				<cfoutput query="rsResult">
					<cfset coord = ''>
					<cfif rsResult.INP_Coordenador eq rsResult.IPT_MatricInspetor>
						<cfset coord = '<strong>(Coordenador(a))</strong>'>
					</cfif>
					-&nbsp;<small>#rsResult.Funome##coord#</small><br>
				</cfoutput>
			</div>
		</div>	
	</nav>
	<main class="main-page cf">
	<section class="principal">
			<header>
				<hgroup>  
					<div align="center" class="card-title"><h2>RECURSOS ALOCADOS NA AVALIAÇÃO - SNCI</h2></div>	
				</hgroup>    	
			</header>

			<div id="vlralocados">
				<cfoutput>
					<form id="form1" action="cadastro_inspecao_despesas.cfm" method="post" name="form1">
						<input type="hidden" id="acao" name="acao" value="">
						<input type="hidden" id="inspecao" name="inspecao" value="#url.numInspecao#">
						
						<table width="40%" align="left" class="table table-bordered table-hover">
							<tr>
								<td colspan="2" align="center"><div><label>Recursos Alocados</label></div></td>
							</tr>
							<tr>
								<td colspan="2"></td>
							</tr>
							<tr>
								<td><div><label>Valor previsto (R$)</label></div></td>
								<td><div><input name="inpvalorprevisto" id="inpvalorprevisto" type="text" class="form-control-sm" value="#LSCurrencyFormat(rsResult.INP_ValorPrevisto, "none")#" size="22" maxlength="18" onKeyPress="numericos()" onKeyUp="moedadig(this.name)">&nbsp;&nbsp<input type="checkbox" id="cbvlrprev" name="cbvlrprev" title="inativo">&nbsp;&nbsp<label>Não se Aplica (Valor previsto)</label></div></td>
							</tr> 
							<tr>
								<td colspan="2"><div><hr></div></td>
							</tr> 
							<tr>
								<td><div><label>Adicional noturno (R$)</label></div></td>
								<td><div><input name="inpadinoturno" id="inpadinoturno" type="text" class="form-control-sm" value="#LSCurrencyFormat(rsResult.INP_AdiNoturno, "none")#" size="22" maxlength="18"  onKeyPress="numericos()" onKeyUp="moedadig(this.name)" onblur="fazersoma()"></div></td>
							</tr> 	
							<tr>
								<td><div><label>Deslocamento(Uber/Táxi/ônibus/Estacionamento/Pedágio) (R$)</label></div></td>
								<td><div><input name="inpdeslocamento" id="inpdeslocamento" type="text" class="form-control-sm" value="#LSCurrencyFormat(rsResult.INP_Deslocamento, "none")#" size="22" maxlength="18"  onKeyPress="numericos()" onKeyUp="moedadig(this.name)" onblur="fazersoma()"></div></td>
							</tr> 	
							<tr>
								<td><div><label>Diárias (R$)</label></div></td>
								<td><div><input name="inpdiarias" id="inpdiarias" type="text" class="form-control-sm" value="#LSCurrencyFormat(rsResult.INP_Diarias, "none")#" size="22" maxlength="18"  onKeyPress="numericos()" onKeyUp="moedadig(this.name)" onblur="fazersoma()"></div></td>
							</tr> 	
							<tr>
								<td><div><label>Passagem aérea (R$)</label></div></td>
								<td><div><input name="inppassagemarea" id="inppassagemarea" type="text" class="form-control-sm" value="#LSCurrencyFormat(rsResult.INP_PassagemArea, "none")#" size="22" maxlength="18"  onKeyPress="numericos()" onKeyUp="moedadig(this.name)" onblur="fazersoma()"></div></td>
							</tr>		
							<tr>
								<td><div><label>Reembolso veículo próprio (R$)</label></div></td>
								<td><div><input name="inpreembveicproprio" id="inpreembveicproprio" type="text" class="form-control-sm" value="#LSCurrencyFormat(rsResult.INP_ReembVeicProprio, "none")#" size="22" maxlength="18"  onKeyPress="numericos()" onKeyUp="moedadig(this.name)" onblur="fazersoma()"></div></td>
							</tr>	
							<tr>
								<td><div><label>Repouso remunerado (R$)</label></div></td>
								<td><div><input name="inprepousoremunerado" id="inprepousoremunerado" type="text" class="form-control-sm" value="#LSCurrencyFormat(rsResult.INP_RepousoRemunerado, "none")#" size="22" maxlength="18"  onKeyPress="numericos()" onKeyUp="moedadig(this.name)" onblur="fazersoma()"></div></td>
							</tr>	
							<tr>
								<td><div><label>Ressarcimento empregado (R$)</label></div></td>
								<td><div><input name="inpressarcirempregado" id="inpressarcirempregado" type="text" class="form-control-sm" value="#LSCurrencyFormat(rsResult.INP_RessarcirEmpregado, "none")#" size="22" maxlength="18"  onKeyPress="numericos()" onKeyUp="moedadig(this.name)" onblur="fazersoma()"></div></td>
							</tr>	
							<tr>
								<td><div><label>Outros (R$)</label></div></td>
								<td><div><input name="inpoutros" id="inpoutros" type="text" class="form-control-sm" value="#LSCurrencyFormat(rsResult.INP_Outros, "none")#" size="22" maxlength="18"  onKeyPress="numericos()" onKeyUp="moedadig(this.name)" onblur="fazersoma()"></div></td>
							</tr>	
							<tr>
								<td colspan="2"><div><hr></div></td>
							</tr>	
							<tr>
								<td><div><label>Total realizado (R$)</label></div></td>
								<td><div><input name="totrealizado" id="totrealizado" type="text" class="form-control-sm" value="" size="22" readOnly>&nbsp;&nbsp<input type="checkbox" id="cbrecursos" name="cbrecursos" title="inativo">&nbsp;&nbsp<label>Não se Aplica (Recursos Alocados)</label></div></td>
							</tr>	
							<tr>
								<td colspan="2"><div><hr></div></td>
							</tr>																														
						</table>
					</form>	
				</cfoutput>				
			</div>
			<br>

			<input type="hidden" name="acao" id="acao" value="">
				
			<table width="100%" align="center" class="table table-hover">
				<tr>
					<td align="center">
						<div class="btnsalvar" align="center" title="Salvar Recursos Alocados"><h5>Salvar Recursos Alocados</h5></div>  
					</td>   
					<td align="center">
						<div class="btnfechar" align="center" title="Fechar"><h5>Fechar</h5></div>  
					</td> 
				</tr>
			</table>
		</section> 
		<aside class="auxiliar">
			<cfoutput>
				<header>
					<br>
					<div id="datasaval"><label>Última atualização</label></div>
				</header>
				<div>				
					<table width="100%" align="center" class="table table-bordered table-hover">	
						<tr>
							<td align="left">
								<h5>Gestor(a)</h5>
							</td>
						</tr>
						<tr>
							<td align="left">
								<small>#rsResult.Usu_Apelido#</small>
							</td>
						</tr>
						<tr>
							<td align="left">
								<h5>Data/Hora</h5>
							</td>
						</tr>
						<tr>
							<td align="left">
								<small>#datetimeformat(rsResult.INP_DTConcluir_Despesas,"dd-mm-yyyy HH:MM:SS")#</small>
							</td>
						</tr>
	
					</table>	
				</div>		
			</cfoutput>			
		</aside>
	</main>
	<footer class="rodape">
	<!---
		<small>Guia Portal da Copa do Mundo Brasil © Copyright 2014 Todos os direitos reservados</small>
		--->
	</footer>
</div> <!-- /.tudo -->
</body>
<script src="public/jquery-3.7.1.min.js"></script>
<script type="text/javascript" src="public/axios.min.js"></script>
<script>
	$(function(e){
		fazersoma()
	})

	function numericos() {
		var tecla = window.event.keyCode;
		//alert(tecla)
		//permite digitação das teclas numéricas (48 a 57, 96 a 105), Delete e Backspace (8 e 46), TAB (9) e ESC (27)	
			if (((tecla < 48) || (tecla > 57))) {
			//alert(tecla);
			event.returnValue = false;
		}
	}
	function fazersoma() {
		let inpadinoturno = $('#inpadinoturno').val()	
		inpadinoturno = inpadinoturno.replaceAll(".", "")
		inpadinoturno = inpadinoturno.replace(",", ".")
		let inpdeslocamento = $('#inpdeslocamento').val()
		inpdeslocamento = inpdeslocamento.replaceAll(".", "")
		inpdeslocamento = inpdeslocamento.replace(",", ".")
		let inpdiarias = $('#inpdiarias').val()
		inpdiarias = inpdiarias.replaceAll(".", "")
		inpdiarias = inpdiarias.replace(",", ".")		
		let inppassagemarea = $('#inppassagemarea').val()
		inppassagemarea = inppassagemarea.replaceAll(".", "")
		inppassagemarea = inppassagemarea.replace(",", ".")		
		let inpreembveicproprio = $('#inpreembveicproprio').val()
		inpreembveicproprio = inpreembveicproprio.replaceAll(".", "")
		inpreembveicproprio = inpreembveicproprio.replace(",", ".")		
		let inprepousoremunerado = $('#inprepousoremunerado').val()
		inprepousoremunerado = inprepousoremunerado.replaceAll(".", "")
		inprepousoremunerado = inprepousoremunerado.replace(",", ".")		
		let inpressarcirempregado = $('#inpressarcirempregado').val()
		inpressarcirempregado = inpressarcirempregado.replaceAll(".", "")
		inpressarcirempregado = inpressarcirempregado.replace(",", ".")		
		let inpoutros = $('#inpoutros').val()
		inpoutros = inpoutros.replaceAll(".", "")
		inpoutros = inpoutros.replace(",", ".")	
		totrealizado = eval(inpadinoturno)+eval(inpdeslocamento)+eval(inpdiarias)+eval(inppassagemarea)+eval(inpreembveicproprio)+eval(inprepousoremunerado)+eval(inpressarcirempregado)+eval(inpoutros)
		$("#totrealizado").val(totrealizado.toLocaleString('pt-br', {minimumFractionDigits: 2}))
	}

	function moedadig(a){
		var valorinfo = $('#'+a).val()
		valorinfo = valorinfo.replaceAll(".", "")
		valorinfo = valorinfo.replace(",", "")
		let tam = valorinfo.length
		let inteiro = valorinfo.substring(0,tam-2)
		let strinteiro = inteiro.toString()
		inteiro=(eval(inteiro))
		let decimal = valorinfo.substring(tam-2,tam)
		//alert('tam: '+tam+' inteiro: '+inteiro+' decimal: '+decimal)
		//if (decimal.length == 1) {decimal = decimal + '0'}
		if(tam == 0){$('#'+a).val('0,00')}
		if(tam == 1 && inteiro == undefined){$('#'+a).val('0,0'+valorinfo)}
		if(tam == 2 && inteiro == undefined){$('#'+a).val('0,'+decimal)}
		if(tam == 3 && inteiro == 0 && decimal == '00'){$('#'+a).val('0,00')}
		if(tam == 3 && inteiro > 0){$('#'+a).val(inteiro+','+decimal)}
		if(tam == 4 && inteiro == 0){$('#'+a).val(inteiro+','+decimal)}
		if(tam == 4 && inteiro > 0){$('#'+a).val(inteiro+','+decimal)}
		if(tam == 5){$('#'+a).val(inteiro+','+decimal)}
		if(tam == 6){
			let milhar = strinteiro.substring(0,1)
			let centena = strinteiro.substring(1,strinteiro.length)
			$('#'+a).val(milhar+'.'+centena+','+decimal)
		}
		if(tam == 7){
			let milhar = strinteiro.substring(0,2)
			let centena = strinteiro.substring(2,strinteiro.length)
			$('#'+a).val(milhar+'.'+centena+','+decimal)
		}
		if(tam == 8){
			let milhar = strinteiro.substring(0,3)
			let centena = strinteiro.substring(3,strinteiro.length)
			$('#'+a).val(milhar+'.'+centena+','+decimal)
		}
		if(tam == 9){
			let milhao = strinteiro.substring(0,1)
			let milhar = strinteiro.substring(1,4)
			let centena = strinteiro.substring(4,strinteiro.length)
			$('#'+a).val(milhao+'.'+milhar+'.'+centena+','+decimal)
		}	
		if(tam == 10){
			let milhao = strinteiro.substring(0,2)
			let milhar = strinteiro.substring(2,5)
			let centena = strinteiro.substring(5,strinteiro.length)
			$('#'+a).val(milhao+'.'+milhar+'.'+centena+','+decimal)
		}	
		if(tam == 11){
			let milhao = strinteiro.substring(0,3)
			let milhar = strinteiro.substring(3,6)
			let centena = strinteiro.substring(6,strinteiro.length)
			$('#'+a).val(milhao+'.'+milhar+'.'+centena+','+decimal)
		}	
		if(tam == 12){
			let bilhao = strinteiro.substring(0,1)
			let milhao = strinteiro.substring(1,4)
			let milhar = strinteiro.substring(4,7)
			let centena = strinteiro.substring(7,strinteiro.length)
			$('#'+a).val(bilhao+'.'+milhao+'.'+milhar+'.'+centena+','+decimal)
		}
		if(tam == 13){
			let bilhao = strinteiro.substring(0,2)
			let milhao = strinteiro.substring(2,5)
			let milhar = strinteiro.substring(5,8)
			let centena = strinteiro.substring(8,strinteiro.length)
			$('#'+a).val(bilhao+'.'+milhao+'.'+milhar+'.'+centena+','+decimal)
		}	
		if(tam == 14){
			let bilhao = strinteiro.substring(0,3)
			let milhao = strinteiro.substring(3,6)
			let milhar = strinteiro.substring(6,9)
			let centena = strinteiro.substring(9,strinteiro.length)
			$('#'+a).val(bilhao+'.'+milhao+'.'+milhar+'.'+centena+','+decimal)
		}				
		//var f2 = valorinfo.toLocaleString('pt-br', {minimumFractionDigits: 2});
	}

	//***************************************************
	// Inicial   Salvar 
	//***************************************************
	$('.btnsalvar').click(function(){
		if (($('#inpvalorprevisto').val() =='' || $('#inpvalorprevisto').val() == '0,00') && $("#cbvlrprev").prop("checked") == false)
			{
				alert('Gestor(a), informar o valor previsto')
				$('#inpvalorprevisto').focus()
				return false
		}	
		if (($('#totrealizado').val() =='' || $('#totrealizado').val() == '0,00') && $("#cbrecursos").prop("checked") == false)
			{
				alert('Gestor(a), informar os recursos alocados')
				$('#inpadinoturno').focus()
				return false
		}
		
		if($('#inpadinoturno').val() == '0,00' || $('#inpdeslocamento').val() == '0,00' || $('#inpdiarias').val() == '0,00' || $('#inppassagemarea').val() == '0,00' || $('#inpreembveicproprio').val() == '0,00' || $('#inprepousoremunerado').val() == '0,00' || $('#inpressarcirempregado').val() == '0,00' || $('#inpoutros').val() == '0,00')
		{
			if(confirm("Gestor(a), há recurso(s) alocado(s) com valore(s) igual '0,00'. \n\nConfirma continuar?")){		
				//return true
			}
			else{
				return false
			}	
		}

		if(confirm("Gestor(a), Confirma salvar?")){
			$('#acao').val('salvar')			
			$('#form1').submit()
		}
		else{
			$('#acao').val('')
			return false
		}			
		
	})

	$('#cbvlrprev').click(function(){  
		let title = $(this).attr('title')
		$('#inpvalorprevisto').val('0,00')
		if(title == 'inativo'){
			$('#cbvlrprev').attr('title','ativo')
			$("#inpvalorprevisto").prop('readonly', true);	
		}else{
			$('#cbvlrprev').attr('title','inativo')
			$("#inpvalorprevisto").prop('readonly', false)
		}
	})	

	$('#cbrecursos').click(function(){  
		let title = $(this).attr('title')
		$('#inpadinoturno').val('0,00')
		$('#inpdeslocamento').val('0,00')
		$('#inpdiarias').val('0,00')
		$('#inppassagemarea').val('0,00')
		$('#inpreembveicproprio').val('0,00')
		$('#inprepousoremunerado').val('0,00')
		$('#inpressarcirempregado').val('0,00')
		$('#inpoutros').val('0,00')
		$('#totrealizado').val('0,00')

		if(title == 'inativo'){
			$('#cbrecursos').attr('title','ativo')
			$("#inpadinoturno").prop('readonly', true)
			$("#inpdeslocamento").prop('readonly', true)
			$("#inpdiarias").prop('readonly', true)
			$("#inppassagemarea").prop('readonly', true)
			$("#inpreembveicproprio").prop('readonly', true)
			$("#inprepousoremunerado").prop('readonly', true)
			$("#inpressarcirempregado").prop('readonly', true)
			$("#inpoutros").prop('readonly', true)
		}else{
			$('#cbrecursos').attr('title','inativo')
			$("#inpadinoturno").prop('readonly', false)
			$("#inpdeslocamento").prop('readonly', false)
			$("#inpdiarias").prop('readonly', false)
			$("#inppassagemarea").prop('readonly', false)
			$("#inpreembveicproprio").prop('readonly', false)
			$("#inprepousoremunerado").prop('readonly', false)
			$("#inpressarcirempregado").prop('readonly', false)
			$("#inpoutros").prop('readonly', false)
		}
	})

	$('.btnfechar').click(function(){
		window.close()
	})

</script>
</html>

