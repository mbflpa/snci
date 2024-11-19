<cfcomponent  >
<cfset dsn_inspecao = 'DBSNCI'>
<cffunction name="tabComponet" returntype="any">
	<cfargument name="listaPaginaInclude" type="any" required="false" default="x,x,x,x"   />
	<cfargument name="listaNomeAbas" type="any" required="false" default="aba1,aba2,aba3,aba4"/>
    <cfargument name="largura" type="numeric" required="false" default="500"/>
	<cfargument name="altura" type="numeric" required="false" default="0"/>
	<cfargument name="titulo" type="string" required="false" default=""/>
    <cfargument name="cor" type="string" required="false" default="transparent;filter:progid:DXImageTransform.Microsoft.gradient(startColorstr=##003366,endColorstr=##003390);"/>

	<cfset listaNomeAbas = listToArray(arguments.listaNomeAbas)>
	<cfset listaPaginaInclude = listToArray(arguments.listaPaginaInclude)>
	<cfset widthAbas =(arguments.largura) / #ArrayLen(listaNomeAbas)#>
	<cfset widthAbas = '#widthAbas#px'>



<html xmlns="http://www.w3.org/1999/xhtml">

	<head>
			<title>SNCI - CADASTRO DE GRUPOS E ITENS</title>
			<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
			<link rel="stylesheet" type="text/css" href="view.css" media="all">
	</head>

					


	<style type="text/css">
			.tablink {
			background-color: #555;
			color: white;
			float: center;
			outline: none;
			cursor: pointer;
			padding: 5px;
			font-size: 12px;

			border:none;

			}

			.tablink:hover{
				background-color:gray!important;	
			}

			.tabcontent {
			color: white;
			display: none;
			padding:10px;
			width: 720px;
			}

	</style>

	 <body id="main_body" style="background:#fff;"> 

			<div id="aguarde" name="aguarde" align="center"  style="width:100%;height:100%;top:0px;left:0px; background:transparent;filter:progid:DXImageTransform.Microsoft.gradient(startColorstr=#7F86b2ff,endColorstr=#7F86b2ff);z-index:1000;visibility:hidden;position:absolute;" >
										
				<img id="imgAguarde" name="imgAguarde" src="figuras/aguarde.png" width="100px"  border="0" style="position:relative;top:50%" ></img>
			</div>
			<div class="tituloDivConsulta">
					<h1 id="titulo" style="background:<cfoutput>#trim(arguments.cor)#</cfoutput>;font-size:14px;width:<cfoutput>#trim(arguments.largura)#px</cfoutput>;text-align:center"><STRONG><cfoutput>#trim(arguments.titulo)#</cfoutput></STRONG></h1>
					<div id="tab"  style="background:<cfoutput>#trim(arguments.cor)#</cfoutput>;width:<cfoutput>#trim(arguments.largura)#</cfoutput>px;">
						
						<div align="center" div="aba">
							<cfloop from="1" to="#ArrayLen(listaNomeAbas)#" index="i" >
								<button onmouseOver="corHover(this);" onMouseOut="corOut(this);" class="tablink" onclick="openPage('<cfoutput>ID#i#</cfoutput>', this, '<cfoutput>#trim(arguments.cor)#</cfoutput>')" style="width:<cfoutput>'#widthAbas#'</cfoutput>" id="<cfoutput>aba#i#</cfoutput>"><cfoutput>#listaNomeAbas[i]#</cfoutput></button>
							</cfloop>
						</div>
						<cfloop from="1" to="#ArrayLen(listaNomeAbas)#" index="i"> 
							<div id="<cfoutput>ID#i#</cfoutput>" class="tabcontent" style="width:<cfoutput>#trim(arguments.largura)#px</cfoutput>;height:<cfoutput>#trim(arguments.altura)#</cfoutput>px;margin-top:10px;padding:10px">           
									<cfif '#i#' le '#ArrayLen(listaPaginaInclude)#'>
										<cfset pagina = "../#listaPaginaInclude[i]#">
										<cfinclude template="#pagina#">
									</cfif>
							</div>
						</cfloop>	
							

					</div>
					
					
			</div>


			<script language="JavaScript" type="text/JavaScript" DEFER="DEFER">
				//inicio controle cor das abas em hover e out
				var txt = navigator.appName;
				
			 	function corHover(aba){
					<cfoutput>
					 var cor='#trim(arguments.cor)#';
					</cfoutput>
					if (txt == 'Microsoft Internet Explorer'){	
						if(aba.style.backgroundColor!=cor && aba.style.backgroundColor!='transparent'){
							aba.style.backgroundColor='gray';
						}
					}
				}
				function corOut(aba){
					if (txt == 'Microsoft Internet Explorer'){
						if(aba.style.backgroundColor == "gray"){
							aba.style.backgroundColor='#555';
						}
					}
				}
				//fim controle cor das abas em hover e out

				//In�cio do bloco de fun��es que controlam as linhas de uma tabela
				//remove a informa��o da linha clicada em uma tabela
				sessionStorage.removeItem('idLinha');
				
				//muda cor da linha ao passar o mouse (se a linha n�o tiver sido selecionada)
				function mouseOver(linha){ 
					if(linha.id !=sessionStorage.getItem('idLinha')){
						linha.style.backgroundColor='#6699CC';
						linha.style.color='#fff';
					}   
				}
				
				//restaura cor da linha ao retirar o mouse (se a linha n�o tiver sido selecionada)
				function mouseOut(linha){
					if(linha.id !=sessionStorage.getItem('idLinha')){
						linha.style.backgroundColor = ''; 
						linha.style.color=''; 
					}else{
						linha.style.backgroundColor='#053c7e';
						linha.style.color='#fff';
					}
					
				}
				//Ao clicar grava a linha clicada, muda a cor da linha clicada e restaura a cor da linha clicada anteriormente
				function gravaOrdLinha(linha){ 
					if(sessionStorage.getItem('idLinha')!=null){
						linhaselecionadaAnterior = document.getElementById(sessionStorage.getItem('idLinha'));
						linhaselecionadaAnterior.style.backgroundColor = ''; 
						linhaselecionadaAnterior.style.color='#053c7e'; 
					}
					var linhaClicada = linha.id;       
					sessionStorage.setItem('idLinha', linhaClicada); 
					linha.style.backgroundColor='#053c7e';
					linha.style.color='#fff';
				}
				//Fim do bloco de fun��es que controlam as linhas de uma tabela

				//Inicio abre janela popup
				function abrirPopup(url,w,h) {
					var newW = w + 100;
					var newH = h + 100;
					var left = (screen.width-newW)/2;
					var top = (screen.height-newH)/2;
					var newwindow = window.open(url, '_blank', 'width='+newW+',height='+newH+',left='+left+',top='+top+ ',scrollbars=no');
					newwindow.resizeTo(newW, newH);
					//posiciona o popup no centro da tela
					newwindow.moveTo(left, top);
					newwindow.focus();

				}	
				//Fim abre janela popup
				
				// Buscar se tem uma aba atual selecionada
				var aba = sessionStorage.getItem('abaAtual');
				if(aba !=null){
					document.getElementById(aba).click(); 
				}else{
					document.getElementById('aba1').click();  
				}
				//fun��o que aciona a espera do submit
				function aguarde(t){
					t="tab";
					if(t !== undefined){
						topo = 100 + document.getElementById(t).offsetTop;
					}else{
						topo = '200';
					}
						if(document.getElementById("aguarde").style.visibility == "visible"){
							document.getElementById("aguarde").style.visibility = "hidden" ;
							document.getElementById("main_body").style.cursor='auto';
						}else{
							document.getElementById("main_body").style.cursor='progress';
							document.getElementById("aguarde").style.visibility = "visible";
							piscando();
						}
						
						document.getElementById("imgAguarde").style.top = topo + 'px';
				}

				function piscando(){
					img = document.getElementById("imgAguarde");
					fundo = document.getElementById("aguarde");                
					if(img.style.visibility == "hidden" & fundo.style.visibility == "visible"){                              
					img.style.visibility = "visible";                         
					}else{                   
					img.style.visibility = "hidden";                       
					}
					
					setTimeout('piscando()', 500);

				}


				//fun��es que controlam as tabs
				function getElementsByClassName(node, classname) {
					var a = [];
					var re = new RegExp('(^| )'+classname+'( |$)');
					var els = node.getElementsByTagName("*");
					for(var i=0,j=els.length; i<j; i++)
						if(re.test(els[i].className))a.push(els[i]);
					return a;
				}

				function openPage(pageName,elmnt,color) {
					// sessionStorage.removeItem('idLinha');
					var i, tabcontent, tablinks;
					tabcontent = getElementsByClassName(document.body,"tabcontent");
					for (i = 0; i < tabcontent.length; i++) {
						tabcontent[i].style.display = "none";
						tabcontent[i].style.background = color;
					}
					tablinks = getElementsByClassName(document.body,"tablink");
					for (i = 0; i < tablinks.length; i++) {
						tablinks[i].style.backgroundColor = "";
					}
					document.getElementById(pageName).style.display = "block";
					elmnt.style.backgroundColor = color;
					// Salvar a aba atual quando aberta
					sessionStorage.setItem('abaAtual', elmnt.id);
					
				}
				//fim fun��es que contronlam as tabs

			</script>
			


	</body>

</html>


</cffunction>
</cfcomponent>