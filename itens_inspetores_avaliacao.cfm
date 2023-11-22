<cfprocessingdirective pageEncoding ="utf-8"/>  
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
 <cfinclude template="aviso_sessao_encerrada.htm">
  <cfabort>
</cfif>       

<cfif isDefined("Session.E01")>
  <cfset StructClear(Session.E01)>
</cfif>


<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select * from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<cfif len(trim(qAcesso.Usu_email)) lte 0>
  <cflocation url="Alterar_permissao_rotinas_inspecao.cfm?svolta=rotinas_inspecao.cfm">
</cfif>
<cfset grpacesso = ucase(Trim(qAcesso.Usu_GrupoAcesso))>

<cfif (grpacesso neq "GESTORES") AND (grpacesso neq "INSPETORES") AND (grpacesso neq "DESENVOLVEDORES")>
  <cfinclude template="aviso_sessao_encerrada.htm">
  <cfabort>
</cfif>             

<cfif trim(qAcesso.Usu_Coordena) neq ''>
    <cfset se= '#qAcesso.Usu_Coordena#'>
<cfelseif qAcesso.Usu_DR eq '04'>
    <cfset se= '04,70'>
<cfelseif qAcesso.Usu_DR eq '10'>
    <cfset se= '10,16'>
<cfelseif qAcesso.Usu_DR eq '06'>
    <cfset se= '06,65'>
<cfelseif qAcesso.Usu_DR eq '26'>
    <cfset se= '26,03'>                                       
<cfelseif qAcesso.Usu_DR eq '28'>
    <cfset se= '28,05'>
<cfelse>
    <cfset se= '#qAcesso.Usu_DR#'>
</cfif>


<cfquery name="qDiretoria" datasource="#dsn_inspecao#">
	Select * FROM Diretoria WHERE Dir_Codigo = '#qAcesso.Usu_DR#'
</cfquery>


<!---AO ACESSAR ESTA PÁGINA,  A MATRÍCULA DO INSPETOR SERÁ RETIRADA DE TODOS OS REGISTROS DOS ITENS Avaliação EM TELA SEM AVALIAÇÃO--->

<cfif '#trim(qAcesso.Usu_GrupoAcesso)#' eq "INSPETORES">
	<cfif isDefined('url.numInspecao')>
		<cfquery datasource="#dsn_inspecao#">
			UPDATE Resultado_Inspecao SET RIP_MatricAvaliador = '' where RIP_MatricAvaliador = '#qAcesso.Usu_Matricula#' and RIP_NumInspecao='#url.numInspecao#'  and RIP_Resposta ='A'
		</cfquery>
	</cfif> 
</cfif> 
<!---------->
<cfif isdefined("url.numInspecao")>
<cfoutput>
	<cfquery datasource="#dsn_inspecao#" name="rsVerificaFinalizacao">
		SELECT RIP_MatricAvaliador FROM Resultado_Inspecao 
		WHERE  RIP_NumInspecao=convert(varchar,'#url.numInspecao#') and (RIP_Resposta ='A' OR RIP_Recomendacao ='S')
	</cfquery>

	<cfquery datasource="#dsn_inspecao#" name="rsQuantInsp">
     	SELECT count(IPT_MatricInspetor) as quantInsp FROM Inspetor_Inspecao 
	    WHERE  IPT_NumInspecao=convert(varchar,'#url.numInspecao#')
	</cfquery>


     <cfquery datasource="#dsn_inspecao#" name="rslistaInspSemAvaliacao">
	    SELECT IPT_MatricInspetor FROM Inspetor_Inspecao 
		LEFT JOIN Resultado_Inspecao ON (IPT_NumInspecao = RIP_NumInspecao) AND (IPT_MatricInspetor = RIP_MatricAvaliador)
        where RIP_MatricAvaliador Is Null AND IPT_NumInspecao=convert(varchar,'#url.numInspecao#')
	 </cfquery>


     <cfquery datasource="#dsn_inspecao#" name="rsInspecaoConcluida">
	    SELECT INP_NumInspecao, INP_Coordenador FROM Inspecao 
		WHERE INP_NumInspecao = convert(varchar,'#url.numInspecao#') and INP_Situacao = 'CO'
	 </cfquery>
	 
     <cfquery datasource="#dsn_inspecao#" name="rsMatricCoord">
	    SELECT INP_Coordenador, INP_Modalidade FROM Inspecao WHERE INP_NumInspecao = convert(varchar,'#url.numInspecao#') 
	 </cfquery>
	<cfquery name="rsRelev" datasource="#dsn_inspecao#">
		SELECT VLR_Fator, VLR_FaixaInicial, VLR_FaixaFinal
		FROM ValorRelevancia
		WHERE VLR_Ano = '#right(url.numInspecao,4)#'
	</cfquery>

</cfoutput>		
</cfif>
<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>

<cfset total=0>


	<cfif isDefined("url.numInspecao")>
		<cfset url.numInspecao = "#url.numInspecao#">
	<cfelse>
		<cfset url.numInspecao = "">
	</cfif>
    <!---verifica se existe algum item em reanálise. Se afirmativo, significa que a avaliação já foi transmitida 
	e o gestor colocou itens em reanálise--->
	<cfquery name="rsItemEmRevisao" datasource="#dsn_inspecao#">
	   SELECT RIP_Resposta,RIP_Recomendacao FROM Resultado_Inspecao 
	   INNER JOIN Inspetor_Inspecao ON RIP_Unidade =IPT_CodUnidade AND RIP_NumInspecao =IPT_NumInspecao
	   WHERE RIP_Recomendacao='S' AND RIP_NumInspecao='#url.numInspecao#'
	</cfquery>
	

	<cfquery name="rsItem" datasource="#dsn_inspecao#">
        SELECT RIP_Unidade,
		       Und_Descricao,
			   Und_TipoUnidade,
			   RIP_NumGrupo,
			   RIP_NumItem,
               RIP_NumInspecao,
               RIP_CodReop,
               RIP_CodDiretoria,
               RIP_Resposta,
			   RIP_Recomendacao,
               RIP_NumGrupo,
			   RIP_MatricAvaliador,
			   RIP_NCISEI,
               Grp_Descricao, 
			   RIP_NumItem, 
			   RIP_Falta,
			   RIP_ReincInspecao,
			   RIP_ReincGrupo,
			   RIP_ReincItem,
			   Itn_Descricao, 
			   Itn_Pontuacao,
			   Itn_Reincidentes,
			   NIP_DtIniPrev, 
			   Itn_Ano, 
			   Grp_Ano,
			   INP_Modalidade,
			   INP_Situacao,
			   TUI_Classificacao,
			   TUI_Pontuacao,	   
			   DENSE_RANK() OVER (ORDER BY TUI_Pontuacao DESC) AS RankByPontuacao
          FROM ((((Numera_Inspecao INNER JOIN Inspecao ON (NIP_NumInspecao = INP_NumInspecao) AND (NIP_Unidade = INP_Unidade)) 
INNER JOIN Unidades ON NIP_Unidade = Und_Codigo) INNER JOIN Resultado_Inspecao ON (INP_NumInspecao = RIP_NumInspecao) AND (INP_Unidade = RIP_Unidade)) 
INNER JOIN Inspetor_Inspecao ON (RIP_NumInspecao = IPT_NumInspecao) AND (RIP_Unidade = IPT_CodUnidade)) 
INNER JOIN (Itens_Verificacao 
INNER JOIN TipoUnidade_ItemVerificacao ON (Itn_NumItem = TUI_ItemVerif) AND (Itn_NumGrupo = TUI_GrupoItem) AND (Itn_Ano = TUI_Ano) AND (Itn_TipoUnidade = TUI_TipoUnid) AND (Itn_Modalidade = TUI_Modalidade)) ON (Und_TipoUnidade = Itn_TipoUnidade) AND (INP_Modalidade = Itn_Modalidade) AND (convert(char(4),RIP_Ano) = Itn_Ano) AND (RIP_NumItem = Itn_NumItem) AND (RIP_NumGrupo = Itn_NumGrupo)
INNER JOIN Grupos_Verificacao ON (Itn_NumGrupo = Grp_Codigo) AND (Itn_Ano = Grp_Ano)
    WHERE RIP_NumInspecao='#url.numInspecao#' 
			AND Itn_Ano=RIGHT('#url.numInspecao#',4) 
        <cfif '#trim(qAcesso.Usu_GrupoAcesso)#' eq "INSPETORES">
			AND IPT_MatricInspetor ='#qAcesso.Usu_Matricula#'
        </cfif>
		<cfif '#trim(qAcesso.Usu_GrupoAcesso)#' eq "GESTORES" or '#trim(qAcesso.Usu_GrupoAcesso)#' eq "DESENVOLVEDORES">
			AND IPT_MatricInspetor = INP_Coordenador
        </cfif>
		<cfif rsItemEmRevisao.recordcount neq 0 >
		    AND  RIP_Recomendacao='S'
		</cfif>
		 ORDER BY RankByPontuacao, Itn_NumGrupo, Itn_NumItem
	</cfquery>

<cfinclude template="cabecalho.cfm">
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<!--- <meta http-equiv="refresh" content="5" > Atualiza a página a cada 5 segundos--->


<script language="JavaScript">
   var index;      // cell index
	// var toggleBool;// sorting asc, desc
	window.onload=function(){
		//recupera a classificação das colunas
		if(sessionStorage.getItem('colClassif')===null){
			toggleBool=true;
			sorting(tbodyItens, 0);
						
		}else{	
			toggleBool=sessionStorage.getItem('colClassifAscDesc');
			// if(toggleBool=='true'){retirado para sempre classificar crescente
			// 	toggleBool = false;
			// }else{
			// 	toggleBool = true;
			// }
			sorting(tbodyItens, sessionStorage.getItem('colClassif'),toggleBool);
		}
		//FIM: recupera a classificação das colunas

		<cfif isdefined("url.Unid")>
			<cfoutput>
				<cfif rsVerificaFinalizacao.recordcount eq 0 and rsInspecaoConcluida.recordcount eq 0 and '#rsMatricCoord.INP_Coordenador#' eq '#qAcesso.Usu_Matricula#'>
					<cfif grpacesso eq "INSPETORES">
						window.setTimeout('liberar()', 100);
					</cfif>
				</cfif>
			</cfoutput>
		</cfif>
	};
	

   //Para classificar tabelas
	
	function sorting(tbody, index){
		sessionStorage.setItem('colClassif', index, toggleBool);
		toggleBool = true;

		var pai = document.getElementById("trItens");
        // for(var i=0; i<pai.children.length; i++){retirado para não classificar a coluna item por solicitação do Adriano
		for(var i=0; i<3; i++){
			var figuraCresceId = 'classifCrescente' + i;
		    var	figuraDecresceId = 'classifDecrescente' + i;
			document.getElementById(figuraCresceId).style.display='none';
			document.getElementById(figuraCresceId).style.visibility='hidden';
			document.getElementById(figuraDecresceId).style.display='none';
			document.getElementById(figuraDecresceId).style.visibility='hidden';
		}


		var frm = document.getElementById('frmopc');
		this.index = index;
		var figuraCresceId = 'classifCrescente' + index;
		var	figuraDecresceId = 'classifDecrescente' + index;
		if(toggleBool){
			toggleBool = false;
			document.getElementById(figuraCresceId).style.display='block';
			document.getElementById(figuraCresceId).style.visibility='visible';
			document.getElementById(figuraDecresceId).style.display='none';
			document.getElementById(figuraDecresceId).style.visibility='hidden';
		}else{
			toggleBool = true;
			document.getElementById(figuraCresceId).style.display='none';
			document.getElementById(figuraCresceId).style.visibility='hidden';
			document.getElementById(figuraDecresceId).style.display='block';
			document.getElementById(figuraDecresceId).style.visibility='visible';
		}

		// sessionStorage.setItem('colClassifAscDesc', toggleBool);retirado para sempre classificar crescente

		var datas= new Array();
		var tbodyLength = tbody.rows.length;
		for(var i=0; i<tbodyLength; i++){
			datas[i] = tbody.rows[i];
		}

		datas.sort(compareCellsGrupo);//obriga a classificação por grupo após escolha da coluna de classificação
		for(var i=0; i<tbody.rows.length; i++){
			tbody.appendChild(datas[i]);
		}

		datas.sort(compareCellsItem);//obriga a classificação por grupo e item após escolha da coluna de classificação
		for(var i=0; i<tbody.rows.length; i++){
			tbody.appendChild(datas[i]);
		}
		
		datas.sort(compareCells);
		for(var i=0; i<tbody.rows.length; i++){
			tbody.appendChild(datas[i]);
		}   
		
		// for(var i = 0; i < pai.children.length; i++){
		for(var i = 0; i < 3; i++){
			if(document.getElementById('classifCrescente' + i)){
				var figuraCresceId = document.getElementById('classifCrescente' + i).style.visibility;
				var	figuraDecresceId = document.getElementById('classifDecrescente' + i).style.visibility;
			}

			if(pai.children[i].tagName == "TH" && (figuraCresceId=='visible' || figuraDecresceId=='visible')) {
				pai.children[i].style.background='lavender';
			}else{
				pai.children[i].style.background='#eeeeee';
			}

		}
	}

	function compareCells(a,b) {
		var aVal = a.cells[index].innerText;
		var bVal = b.cells[index].innerText;

		aVal = aVal.replace(/\,/g, '');
		bVal = bVal.replace(/\,/g, '');

		if(toggleBool){
			var temp = aVal;
			aVal = bVal;
			bVal = temp;
		} 

		if(aVal.match(/^[0-9]+$/) && bVal.match(/^[0-9]+$/)){
			return parseFloat(aVal) - parseFloat(bVal);
		}
		else{
			if (aVal < bVal){
				return -1; 
			}else if (aVal > bVal){
					return 1; 
			}else{
				return 0;       
			}         
		}
	}
	function compareCellsGrupo(a,b) {
		var aVal = a.cells[2].innerText;
		var bVal = b.cells[2].innerText;

		aVal = aVal.replace(/\,/g, '');
		bVal = bVal.replace(/\,/g, '');

		if(toggleBool){
			var temp = aVal;
			aVal = bVal;
			bVal = temp;
		} 

		if(aVal.match(/^[0-9]+$/) && bVal.match(/^[0-9]+$/)){
			return parseFloat(aVal) - parseFloat(bVal);
		}
		else{
			if (aVal < bVal){
				return -1; 
			}else if (aVal > bVal){
					return 1; 
			}else{
				return 0;       
			}         
		}
	}
	function compareCellsItem(a,b) {
		var aVal = a.cells[3].innerText;
		var bVal = b.cells[3].innerText;

		aVal = aVal.replace(/\,/g, '');
		bVal = bVal.replace(/\,/g, '');

		if(toggleBool){
			var temp = aVal;
			aVal = bVal;
			bVal = temp;
		} 

		if(aVal.match(/^[0-9]+$/) && bVal.match(/^[0-9]+$/)){
			return parseFloat(aVal) - parseFloat(bVal);
		}
		else{
			if (aVal < bVal){
				return -1; 
			}else if (aVal > bVal){
					return 1; 
			}else{
				return 0;       
			}         
		}
	}
	



	//FIM: Para classificar tabelas

    //captura a posição do scroll (usado nos botões que chamam outras páginas)
    //e salva no sessionStorage
    function capturaPosicaoScroll(){
        sessionStorage.setItem('scrollpos', document.body.scrollTop);
		
    }
	//após o onload recupera a posição do scroll armazenada no sessionStorage e reposiciona-o conforme última localização
        var scrollpos = 0;
		if(sessionStorage.getItem('scrollpos')){
			scrollpos = sessionStorage.getItem('scrollpos');
		}
		setTimeout(function () {
           window.scrollTo(0, scrollpos);
		   sessionStorage.setItem('scrollpos', '0');
		
        },200);
	
	
	//ao fechar, atualiza a página que abriu esta.
    window.onbeforeunload = function() {
     //   window.opener.location.reload();
    }

	var bd = document.getElementsByTagName('body')[0];
	var time = new Date().getTime();


	bd.onmousemove = goLoad;

	function goLoad() {
	if(new Date().getTime() - time >= 50000) {
		time = new Date().getTime();
		aguarde2();
		setTimeout("window.location = document.URL;",1000);
		// window.location.reload(true);
		}else{
			time = new Date().getTime();
		}
	}




	top.window.moveTo(0,0);
	if (document.all)
	{ top.window.resizeTo(screen.availWidth,screen.availHeight); }
	else if
	(document.layers || document.getElementById)
	{
	if
	(top.window.outerHeight < screen.availHeight || top.window.outerWidth <
	screen.availWidth)
	{ top.window.outerHeight = top.screen.availHeight;
	top.window.outerWidth = top.screen.availWidth; }
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

	function aguarde2(){
	
		if(document.getElementById("aguarde").style.visibility == "visible"){
		document.getElementById("aguarde").style.visibility = "hidden" ;
		}else{
		document.getElementById("aguarde").style.visibility = "visible";
		piscando();
		}
	}
	function aguarde(){
		document.getElementById("aguarde").style.visibility = "visible";
	}

	//detectando navegador
	sAgent = navigator.userAgent;
	bIsIE = sAgent.indexOf("MSIE") > -1;
	bIsNav = sAgent.indexOf("Mozilla") > -1 && !bIsIE;

	//setando as variaveis de controle de eventos do mouse

	var xmouse = 0;
	var ymouse = 0;
	document.onmousemove = MouseMove;

	//funcoes de controle de eventos do mouse:
	function MouseMove(e){
	if (e) { MousePos(e); } else { MousePos();}
	}

	function MousePos(e) {
	if (bIsNav){
	xmouse = e.pageX;
	ymouse = e.pageY;
	}
	if (bIsIE) {
	xmouse = document.body.scrollLeft + event.x;
	ymouse = document.body.scrollTop + event.y;
	}
	}

	//funcao que mostra e esconde o hint
	function Hint(objNome, action){
	//action = 1 -> Esconder
	//action = 2 -> Mover

	if (bIsIE) {
		objHint = document.all[objNome];
		}
		if (bIsNav) {
		objHint = document.getElementById(objNome);
		event = objHint;
		}

		switch (action){
		case 1: //Esconder
		objHint.style.visibility = "hidden";
		break;
		case 2: //Mover
		objHint.style.visibility = "visible";
		objHint.style.left = xmouse + 15;
		objHint.style.top = ymouse + 15;
		break;
		}

	}


	function abrirInspecao(url) {
	aguarde();
	sessionStorage.clear();
	// return false;
	var newwindow = window.open(url,'_self');

	}


	<cfset listaInspSemAval="">
	<cfset quantListaInspSemAval = 0>
	<cfset inspComAval ="">
	<!---<cfset coordLocalizListaSemAval ="">--->

	//função que starta o processo de liberação
	function liberar(){
	 if (document.frmopc.acao.value != 'liberaval')
	 {
	 document.frmopc.acao.value = '';
	 return false;
	 }
	 
	 var auxcam = " \n\nSr.(a) Inspetor(a) esta opção finaliza a ação de Avaliação e Reanálise de Itens do relatório.\n\nConfirma em Liberar Relatório?";
	 
	 if (confirm ('            Atenção!' + auxcam))
		 {
//**************************************************************************
<CFOUTPUT>
			<cfif isdefined("url.Unid")>
			<cfif rsVerificaFinalizacao.recordcount eq 0 and rsInspecaoConcluida.recordcount eq 0>
					document.getElementById("aguarde").style.visibility = "visible";
						
							<!---seta a varável com a lista de inspetores que não realizaram avaliações --->
							<cfset listaInspSemAval = ValueList(rslistaInspSemAvaliacao.IPT_MatricInspetor,", ")>
							<cfset quantListaInspSemAval = ListLen('#listaInspSemAval#')>
							<!---seta a varável com a quant. de inspetores que fizeram avaliações(diferença entre a quabtidade de inspetores cadastrados na Avaliação e a quant. de inspetores que não realizaram avaliações--->
							<cfset inspComAval ='#rsQuantInsp.quantInsp#' - '#rslistaInspSemAvaliacao.recordcount#'>

						<!---Verifica se a quant. de inspetores cadastrados menos a quant. de inspetores sem avaliações é iguual a um, caso afirmativo, mostra mensagem e cancela a liberação --->
						
						<cfif  '#inspComAval#' eq 1>
								var m = "As avaliações dos itens da Avaliação foram realizadas por 1 (um) Inspetor.\n\nA liberação desta Avaliação está condicionada à avaliação dos itens por pelo menos 2 (dois) Inspetores.\n\nInspetores sem avaliações realizadas: " + '#listaInspSemAval#';
								alert(m);
								document.getElementById("aguarde").style.visibility = "hidden";
								return false;
						</cfif>
						
						if(window.confirm('Todos os itens do Relatório de Avaliação foram avaliados!\n\nDeseja prosseguir com a liberação do Relatório para revisão da SCOI?')){
									var confirmacao ="";
										<!---Exclui os inspetores que não realizaram avaliações--->
										<!---se a quantidade de inspetores com avaliação for maior que 1 e o coordenador não estiver na lista de inspetores sem avaliação, executa a exclusão dos inspetores desta lista da inspeção antes de liberá-la para revisão--->
										<cfif  '#inspComAval#' gt 1 and '#quantListaInspSemAval#' gte 1>
											<!---se a quantidade de inspetores sem avaliação for igual a 1--->									
											<cfif  '#quantListaInspSemAval#' eq 1>
												confirmacao = "O Inspetor " + '#listaInspSemAval#' +" não avaliou nenhum item da Avaliação.\n\nCaso prossiga com a liberação desta Avaliação para revisão, o Inspetor será excluído do cadastro da Avaliação.\n\nConfirma a exclusão do Inspetor e a liberação da Avaliação?";									
											</cfif>
											<!---se a quantidade de inspetores sem avaliação for maior ou igual a 2--->
											<cfif  '#quantListaInspSemAval#' gte 2>
												confirmacao = "Os Inspetores listados a seguir não avaliaram nenhum item da Avaliação:\n\n" + '#listaInspSemAval#' +"\n\nCaso prossiga com a liberação desta Avaliação para revisão, os Inspetores serão excluídos do cadastro da Avaliação.\n\nConfirma a exclusão dos Inspetores e a liberação da Avaliação?";
											</cfif>
												if(window.confirm(confirmacao)){ 
													document.getElementById("aguarde").style.visibility = "hidden";		
												}else{
													document.getElementById("aguarde").style.visibility = "hidden";
													return false;
												}
										</cfif>
										var url='itens_inspetores_avaliacao.cfm?acao=validar&numInspecao=#url.numInspecao#&Unid=#url.Unid#&tpunid=#rsItem.Und_TipoUnidade#';
										window.open(url,'_self');
							}else{
									document.getElementById("aguarde").style.visibility = "hidden";
									return false;
							}
				</cfif>
			</cfif>
		</CFOUTPUT>
//**************************************************************************
		}
		else
		   {
			 if (sit != 23) {document.form1.cbData.disabled = true};
			 return false;
		  }
	}
//-------------------------------------------------------------------------
	//Início do bloco de funções que controlam as linhas de uma tabela
	//remove a informação da linha clicada em uma tabela
	// sessionStorage.removeItem('idLinha'); 
	setTimeout(function () {
		if(sessionStorage.getItem('idLinha')){
			if(document.getElementById(sessionStorage.getItem('idLinha'))){
				var linha =document.getElementById(sessionStorage.getItem('idLinha'));
				linha.style.backgroundColor='#053c7e';
				linha.style.color='#fff';
			}
			
		}
	},200);
	//muda cor da linha ao passar o mouse (se a linha não tiver sido selecionada)
	function mouseOver(linha){ 
		if(linha.id !=sessionStorage.getItem('idLinha')){
			linha.style.backgroundColor='#6699CC';
			linha.style.color='#fff';
		}   
	}
	
	//restaura cor da linha ao retirar o mouse (se a linha não tiver sido selecionada)
	function mouseOut(linha){
		if(linha.id !=sessionStorage.getItem('idLinha')){
			linha.style.backgroundColor = ''; 
			linha.style.color='#053c7e';
		}else{
			linha.style.backgroundColor='#053c7e';
			linha.style.color='#fff';
		}
		
	}
	//Ao clicar grava a linha clicada, muda a cor da linha clicada e restaura a cor da linha clicada anteriormente
	function gravaOrdLinha(linha){ 
		if(sessionStorage.getItem('idLinha')){
			var linhaAnterior = sessionStorage.getItem('idLinha');
			if(document.getElementById(linhaAnterior)){
				linhaselecionadaAnterior = document.getElementById(sessionStorage.getItem('idLinha'));
				linhaselecionadaAnterior.style.backgroundColor = ''; 
				linhaselecionadaAnterior.style.color='#053c7e'; 
			}
		}
		var linhaClicada = linha.id;       
		sessionStorage.setItem('idLinha', linhaClicada);						
		linha.style.backgroundColor='#053c7e';
		linha.style.color='#fff';
	}
	//Fim do bloco de funções que controlam as linhas de uma tabela


</script>

<style>
#form_container
{
	background:#fff;
	margin:0 auto;
	text-align:left;
	width:720px;
}
h1
{
	background-color:#6699CC;
	margin:0;
	min-height:0;
	padding:5px;
	text-decoration:none;
	Color:#fff;
	
}

h1 a
{
	
	display:block;
	height:100%;
	min-height:40px;
	overflow:hidden;
}

.validar{
	cursor:pointer;
	font-size:20px!important;
	background:red;
	color:#fff;
	padding:8px;
	border-style: solid;
    border-width: 5px;
	border-color:#fff;
	
}

.validar:hover{
background:#6699CC;	
}


			
</style>



</head>
<body onLoad="mouseOver(8)">
	<div id="aguarde" name="aguarde" align="center"  style="width:100%;height:200%;top:105px;left:10px; background:transparent;filter:progid:DXImageTransform.Microsoft.gradient(startColorstr=#7F86b2ff,endColorstr=#7F86b2ff);z-index:10000;visibility:hidden;position:absolute;" >		
		<img id="imgAguarde" name="imgAguarde"src="figuras/aguarde.png" width="100px"  border="0" style="position:relative;top:20%"></img>
	</div>




<form id="frmopc" action="itens_inspetores_avaliacao.cfm" method="get"  enctype="multipart/form-data"  name="frmopc" >

	<table width="100%" height="50%">

	<tr>

	<input name="StatusSE" type="hidden" id="StatusSE" value="<cfoutput>#qAcesso.Usu_DR#</cfoutput>">
	<input name="url.numInspecao" type="hidden" id="url.numInspecao" value="<cfoutput>#url.numInspecao#</cfoutput>">
	<input name="SE" type="hidden" id="SE" value="<cfoutput>#qAcesso.Usu_DR#</cfoutput>">   

	<cfif isDefined("Submit1")>
	   <input name="Submit1" type="hidden" id="Submit1" value="<cfoutput>#Submit1#</cfoutput>">
	<cfelse>
		<cfset  Submit1 = ''>  
	</cfif>
	<cfif isDefined("Submit2")>
		<input name="Submit2" type="hidden" id="Submit2" value="<cfoutput>#Submit2#</cfoutput>">
	<cfelse>
		<cfset  Submit2 = ''>  
	</cfif>
	<cfif isDefined("Submit3")>
		<input name="Submit3" type="hidden" id="Submit3" value="<cfoutput>#Submit3#</cfoutput>">
	<cfelse>
		<cfset  Submit3 = ''>  
	</cfif>



<cfif isdefined("url.acao")>
    <cfif "#url.acao#" eq "validar">
		<!--- Rotina de finalização da avaliação--->
		<cfquery name="rsInspecaoFinalizar" datasource="#dsn_inspecao#">
			SELECT  RIP_NumInspecao,INP_Situacao 
			FROM Resultado_Inspecao 
			INNER JOIN Inspecao ON INP_NumInspecao = RIP_NumInspecao
			WHERE RIP_NumInspecao='#url.numInspecao#' and RIP_Resposta='A'
		</cfquery>
		<!---Seleciona os itens não conformes da tabela Resultado_Inspecao--->
		<cfquery name="rsInspecaoFinalizarNC" datasource="#dsn_inspecao#">
			SELECT  RIP_NumInspecao FROM Resultado_Inspecao WHERE RIP_NumInspecao='#url.numInspecao#' and RIP_Resposta='N'
		</cfquery>
			
		<!---Se não existirem mais itens não avaliados para esta Avaliação, inicializa o cadastro nas tabelas ProcessoParecerUnidade, ParecerUnidade e Andamento e atualiza a tabela Inspecao de 'NA' para 'CO' --->
		<!--- Se ocorrerem erros em uma das query a seguir, será feitoum rollback dos registros--->
		<cftransaction>
		<!---exclui os inspetores de Inspetor_Inspecao que estão na lista e somar as horas de pre-inspeção e inspeção da tabela inspetor_inspecao e faz um update na tabela inspecao com a nova soma--->
		
			<cfif '#quantListaInspSemAval#' gte 1>
				<cfquery  datasource="#dsn_inspecao#">
				DELETE FROM Inspetor_Inspecao WHERE IPT_NumInspecao = convert(varchar,'#url.numInspecao#') and IPT_MatricInspetor in(#listaInspSemAval#)
				</cfquery>
			</cfif>
			<cfquery datasource="#dsn_inspecao#" name="rsResumo">
					SELECT min(IPT_DtInicDesloc)  as dtInicDeslocMin, 
						   max(IPT_DtFimDesloc)   as dtFimDesloclMax,
						   min(IPT_DtInicInsp)    as dtInicInspMin, 
						   max(IPT_DtFimInsp)     as dtFimInspMax,
						   SUM(IPT_NumHrsPreInsp) as numHrsPreInspTotal,
						   max(IPT_NumHrsDesloc)  as numHrsDeslocTotal,
						   SUM(IPT_NumHrsInsp)    as numHrsInspTotal
					FROM Inspetor_Inspecao WHERE IPT_NumInspecao = '#url.numInspecao#'
			</cfquery>
			<cfquery datasource="#dsn_inspecao#">
				UPDATE inspecao SET INP_HrsPreInspecao =     '#rsResumo.numHrsPreInspTotal#', 
									INP_DtInicDeslocamento = '#rsResumo.dtInicDeslocMin#',
									INP_DtFimDeslocamento =  '#rsResumo.dtFimDesloclMax#',
									INP_HrsDeslocamento=     '#rsResumo.numHrsDeslocTotal#',
									INP_HrsInspecao =        '#rsResumo.numHrsInspTotal#'
				WHERE INP_NumInspecao = '#url.numInspecao#' 
			</cfquery> 

			<cfif "#rsInspecaoFinalizar.recordcount#" eq 0 and "#rsInspecaoFinalizarNC.recordcount#" neq 0>
				<!---Insert na tabela ProcessoParecerUnidade --->
				<cfquery datasource="#dsn_inspecao#" name="rsExistePRPAUN">
				   SELECT Pro_Unidade FROM ProcessoParecerUnidade WHERE Pro_Inspecao = '#url.numInspecao#'
				</cfquery>
				<cfif rsExistePRPAUN.recordcount lte 0>
					<cfquery datasource="#dsn_inspecao#">
						INSERT INTO ProcessoParecerUnidade (Pro_Unidade, Pro_Inspecao, Pro_Situacao, Pro_DtEncerr, Pro_username, Pro_dtultatu) 
						VALUES ('#url.Unid#', '#url.numInspecao#', 'AB', NULL, '#qAcesso.Usu_Matricula#', GETDATE())
					</cfquery> 
				</cfif>
				<!---Seleciona os itens não conformes da tabela Resultado_Inspecao--->
				<cfquery name="rsInspecaoFinal" datasource="#dsn_inspecao#">
					SELECT * FROM Resultado_Inspecao 
					INNER JOIN Inspecao ON (RIP_NumInspecao = INP_NumInspecao) AND (RIP_Unidade =INP_Unidade) 
					WHERE RIP_NumInspecao='#url.numInspecao#' and RIP_Resposta='N'
				</cfquery>
				<!---  --->
				<!--- Realizar um loop cadastrando os itens não conformes nas tabelas ParecerUnidade e Andamento --->
                <cfoutput query="rsInspecaoFinal">
					<!--- Dado default para registro no campo Pos_Area --->
					<cfset posarea_cod = '#RIP_Unidade#'>
						
					<!--- Obter o tipo da Unidade e sua descrição para alimentar o Pos_AreaNome --->
					<cfquery name="rsUnid" datasource="#dsn_inspecao#">
						SELECT Und_Centraliza, Und_Descricao, Und_TipoUnidade FROM Unidades WHERE Und_Codigo = '#RIP_Unidade#'
					</cfquery>
					<!--- Dado default para registro no campo Pos_AreaNome --->
					<cfset posarea_nome = rsUnid.Und_Descricao>

					<!--- Buscar o tipo de TipoUnidade que pertence a resposta do item --->
					<cfquery name="rsItem2" datasource="#dsn_inspecao#">
						SELECT Itn_TipoUnidade, Itn_Pontuacao, Itn_Classificacao, Itn_PTC_Seq
						FROM Itens_Verificacao 
						WHERE (Itn_Ano = right('#url.numInspecao#',4)) and (Itn_NumGrupo = '#RIP_NumGrupo#') AND (Itn_NumItem = '#RIP_NumItem#') and (Itn_TipoUnidade = #url.tpunid#) and (Itn_Modalidade = '#rsInspecaoFinal.Inp_Modalidade#')
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
					<!--- composic: #composic# ItnPontuacao: #ItnPontuacao#   ClasItem_Ponto: #ClasItem_Ponto#   impactosn: #impactosn#   fator: #fator# RIP_Falta: #rsInspecaoFinal.RIP_Falta#<br> --->
					
					<cfif impactosn eq 'S'>
						 <cfset somafaltasobra = rsInspecaoFinal.RIP_Falta>
						 <cfif (RIP_NumItem eq 1 and (RIP_NumGrupo eq 53 or RIP_NumGrupo eq 72 or RIP_NumGrupo eq 214 or RIP_NumGrupo eq 284))>
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
					<cfif ClasItem_Ponto eq 'LEVE'	and len(trim(rsInspecaoFinal.RIP_REINCINSPECAO)) gt 0>
					  <cfset ClasItem_Ponto = 'MEDIANO'>
					</cfif>						
					<!--- composic: #composic# ItnPontuacao: #ItnPontuacao#   ClasItem_Ponto: #ClasItem_Ponto#   impactosn: #impactosn#  fator: #fator# RIP_Falta: #rsInspecaoFinal.RIP_Falta#  somafaltasobra: #somafaltasobra#<br> --->			
					<cfquery name="rsExistePaUn" datasource="#dsn_inspecao#">
						select Pos_Unidade from ParecerUnidade where Pos_Unidade = '#RIP_Unidade#' and Pos_Inspecao='#url.numInspecao#' and Pos_NumGrupo=#RIP_NumGrupo# and Pos_NumItem = #RIP_NumItem#
					</cfquery>			
					<cfif rsExistePaUn.recordcount lte 0>
						    <cfquery datasource="#dsn_inspecao#">
								INSERT INTO ParecerUnidade (Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_NomeResp, Pos_Situacao, Pos_Parecer, Pos_co_ci, Pos_dtultatu, Pos_username, Pos_aval_dinsp, Pos_Situacao_Resp, Pos_Area, Pos_NomeArea, Pos_NCISEI, Pos_PontuacaoPonto, Pos_ClassificacaoPonto) 
								VALUES ('#RIP_Unidade#', '#url.numInspecao#', #RIP_NumGrupo#, #RIP_NumItem#, 
										CONVERT(char, GETDATE(), 102), '#CGI.REMOTE_USER#', 'RE', '', 'INTRANET', CONVERT(char, GETDATE(), 120), '#CGI.REMOTE_USER#', NULL, 0,
										'#posarea_cod#','#posarea_nome#','#RIP_NCISEI#',#ItnPontuacao#,'#ClasItem_Ponto#')
							</cfquery>
					<cfelse>							
						    <cfquery datasource="#dsn_inspecao#">
								update ParecerUnidade set Pos_DtPosic=CONVERT(char, GETDATE(), 102), Pos_NomeResp='#CGI.REMOTE_USER#', Pos_Situacao='RE', Pos_Parecer='', Pos_co_ci='INTRANET', Pos_dtultatu=CONVERT(char, GETDATE(), 120), Pos_username='#CGI.REMOTE_USER#', Pos_aval_dinsp=NULL, Pos_Situacao_Resp=0, Pos_Area='#posarea_cod#', Pos_NomeArea='#posarea_nome#', Pos_NCISEI='#RIP_NCISEI#', Pos_PontuacaoPonto=#ItnPontuacao#, Pos_ClassificacaoPonto='#ClasItem_Ponto#'
								where Pos_Unidade='#RIP_Unidade#' and Pos_Inspecao='#url.numInspecao#' and Pos_NumGrupo=#RIP_NumGrupo# and Pos_NumItem=#RIP_NumItem#
							</cfquery>					
					</cfif>						
						<!---Fim Insere ParecerUnidade --->
		
						<!---UPDATE em Inspecao--->
						<!---Verifica se existem itens com status NÃO VERIFICADO ou NÃO EXECUTA (com Itn_ValidacaoObrigatoria = 1)--->
						<cfquery datasource="#dsn_inspecao#" name="rsVerifValidados">
							SELECT RIP_Resposta, RIP_Recomendacao,Itn_ValidacaoObrigatoria 
							FROM Resultado_Inspecao 
							INNER JOIN Inspecao on RIP_NumInspecao = INP_NumInspecao and RIP_Unidade = INP_Unidade
							INNER JOIN Itens_Verificacao ON Itn_Ano = convert(char(4),RIP_Ano) AND Itn_NumGrupo = RIP_NumGrupo AND Itn_NumItem = RIP_NumItem and inp_Modalidade = itn_modalidade
							INNER JOIN Unidades ON Und_Codigo = RIP_Unidade and (Itn_TipoUnidade = Und_TipoUnidade)
							WHERE ((RTRIM(RIP_Resposta)= 'E' AND Itn_ValidacaoObrigatoria=1) OR RTRIM(RIP_Resposta)= 'V') AND RTRIM(RIP_Recomendacao) IS NULL AND RIP_NumInspecao='#url.numInspecao#' and RIP_Unidade='#RIP_Unidade#' 
						</cfquery>

						<!---  --->
						<cfquery datasource="#dsn_inspecao#" >
							UPDATE Inspecao SET INP_Situacao = 'CO'
							<!--- , INP_DtFimInspecao =  CONVERT(char, GETDATE(), 102) --->
							, INP_DtEncerramento =  CONVERT(char, GETDATE(), 102)
							, INP_DtUltAtu =  CONVERT(char, GETDATE(), 120)
							, INP_UserName = '#CGI.REMOTE_USER#'
							WHERE INP_Unidade='#RIP_Unidade#' AND INP_NumInspecao='#url.numInspecao#' 
						</cfquery> 
						<!---Fim UPDATE em Inspecao --->
					
						<!--- Inserindo dados dados na tabela Andamento --->
						<cfset andparecer = #posarea_cod#  & " --- " & #posarea_nome#>
						<cfquery name="rsExisteAND" datasource="#dsn_inspecao#">
							select And_Unidade from Andamento where And_Unidade = '#RIP_Unidade#' and And_NumInspecao='#url.numInspecao#' and And_NumGrupo=#RIP_NumGrupo# and And_NumItem = #RIP_NumItem# and And_Situacao_Resp = 0
						</cfquery>
						<cfif rsExisteAND.recordcount lte 0>						
							<cfquery datasource="#dsn_inspecao#">
								insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, and_Parecer, And_Area) 
								values ('#url.numInspecao#', '#RIP_Unidade#', #RIP_NumGrupo#, #RIP_NumItem#, convert(char, getdate(), 102), '#CGI.REMOTE_USER#', 0, CONVERT(char, GETDATE(), 108), '#andparecer#', '#posarea_cod#')
							</cfquery>
						</cfif>	 
					<!---Fim Insere Andamento --->
				</cfoutput>
			    <!---Fim do loop--->
			<cfelse>
				    <!---SE NÃO EXISTIREM MAIS ITENS PARA AVALIAÇÃO E NÃO EXISTIREM ITENS NÃO CONFORME--->
					<!---Insert na tabela ProcessoParecerUnidade --->				
				   <cfif "#rsInspecaoFinalizar.recordcount#" eq 0 and "#rsInspecaoFinalizarNC.recordcount#" eq 0>
						<cfquery datasource="#dsn_inspecao#">
							INSERT INTO ProcessoParecerUnidade (Pro_Unidade, Pro_Inspecao, Pro_Situacao, Pro_DtEncerr, Pro_username, Pro_dtultatu) 
							VALUES ('#url.Unid#', '#url.numInspecao#', 'AB', NULL, '#qAcesso.Usu_Matricula#', GETDATE())
						</cfquery> 

					<!---  --->						
						<!---UPDATE em Inspecao--->
												
						<cfquery datasource="#dsn_inspecao#" >
							UPDATE Inspecao SET INP_Situacao = 'CO'
							, INP_DtEncerramento =  CONVERT(char, GETDATE(), 102)
							, INP_DtUltAtu =  CONVERT(char, GETDATE(), 120)
							, INP_UserName ='#CGI.REMOTE_USER#'
							WHERE INP_NumInspecao='#url.numInspecao#' 
						</cfquery> 
						<!---Fim UPDATE em Inspecao --->
					</cfif>
			</cfif>
	     </cftransaction>
	  <!---Fim da rotina de finalização da avaliação--->	
	   <cflocation url="Pacin_ClassificacaoUnidades.cfm?&pagretorno=itens_inspetores_avaliacao.cfm&Unid=#url.unid#&Ninsp=#url.numInspecao#">
	<!---   <cflocation url = "itens_inspetores_avaliacao.cfm?numInspecao=#url.numInspecao#&Unid=#url.unid#" addToken = "no"> --->
	</cfif>

</cfif>


<td valign="top" align="center">
	
<!--- Área de conteúdo   --->

        <cfif '#trim(qAcesso.Usu_GrupoAcesso)#' eq "INSPETORES">   
		<!---Inspeções NA = não avaliadas, ER = em reavaliação, RA =reavaliada--->
			<cfquery datasource="#dsn_inspecao#" name="rsInspecoes">
				SELECT * FROM Inspecao 
				INNER JOIN Inspetor_Inspecao on IPT_NumInspecao = INP_NumInspecao
				INNER JOIN Numera_Inspecao on NIP_NumInspecao = INP_NumInspecao
				WHERE (Rtrim(INP_Situacao) = 'NA' or Rtrim(INP_Situacao) = 'ER') 
					and NIP_Situacao = 'A'
					and IPT_MatricInspetor ='#qAcesso.Usu_Matricula#' 
				ORDER BY INP_DtInicInspecao
			</cfquery>
		</cfif> 
		<cfif '#trim(qAcesso.Usu_GrupoAcesso)#' eq "GESTORES" OR '#trim(qAcesso.Usu_GrupoAcesso)#' eq "DESENVOLVEDORES">  
		<!---Inspeções NA = não avaliadas, ER = em reavaliação, RA =reavaliada--->  
			<cfquery datasource="#dsn_inspecao#" name="rsInspecoes">
				SELECT * FROM Inspecao 
				INNER JOIN Numera_Inspecao on NIP_NumInspecao = INP_NumInspecao
				WHERE (Rtrim(INP_Situacao) = 'NA' or Rtrim(INP_Situacao) = 'ER')
					and NIP_Situacao = 'A'
					and left(INP_NumInspecao,2) in(#se#)
				ORDER BY INP_DtInicInspecao
			</cfquery>
		</cfif>

		<div id="form_container" align="center" style="background:transparent;margin-bottom:0px">
				<div align="center"><strong class="titulo1">AVALIAÇÃO DOS ITENS DE CONTROLE INTERNO</strong></div>
			<br>
			<cfif '#rsInspecoes.recordCount#' eq 0>
				<h1 style="background:#005782">
					<div align="center"><label style="font-size:14px;font-family:Verdana, Arial, Helvetica, sans-serif" >NÃO EXISTEM AVALIAÇÕES PENDENTES PARA O INSPETOR <br><cfoutput>#qAcesso.Usu_Apelido# (#trim(qAcesso.Usu_Matricula)#)</cfoutput></label><br>
					</div>
				</h1>
					<cfif isdefined("url.numInspecao") AND '#url.numInspecao#' NEQ "">

						<cfquery datasource="#dsn_inspecao#" name="rsInspecoesFinalizada">
							SELECT * FROM Inspecao 
							WHERE INP_Situacao = 'NA' and INP_NumInspecao = '#url.numInspecao#';
						</cfquery>
           
						<cfquery datasource="#dsn_inspecao#" name="rsInspecoesFinalizada2">
							SELECT * FROM Inspecao 	
							INNER JOIN Inspetor_Inspecao on IPT_NumInspecao = INP_NumInspecao				
							WHERE INP_Situacao = 'CO' and IPT_MatricInspetor ='#qAcesso.Usu_Matricula#'  and INP_NumInspecao = '#url.numInspecao#'
						</cfquery>
						<cfquery datasource="#dsn_inspecao#" name="rsUnidade">
							SELECT Und_Codigo, Und_Descricao FROM Unidades WHERE Und_Codigo ='#rsInspecoesFinalizada2.INP_Unidade#'
						</cfquery>


						<br><br>
						<div align="center" style="position:relative;top:10px;font-size:18px;color:#005782"><strong ><cfoutput>#url.numInspecao# - #trim(rsUnidade.Und_Descricao)# (#rsUnidade.Und_Codigo#)</cfoutput></strong></div>
						<br>
						<div align="center" style="position:relative;top:10px;font-size:18px;color:#005782"><strong >Todos os itens da Avaliação de Controle realizada na unidade foram executados com sucesso e foram submetidos à REVISÃO da SCOI.<BR>Os itens estarão liberados para visualização dos Inspetores Regionais e da unidade verificada após o término da revisão.</strong>
							<br><br>
							<button onClick="window.close()" class="botao">Fechar</button> 
						</div>
						<br>
					<cfelse>
						<div align="center" style="position:relative;top:10px;font-size:18px;color:#005782">
							<br><br>
							<button onClick="window.close()" class="botao">Fechar</button> 
						</div>
					</cfif> 

				<cfelse>
					<h1  >
						<!--- <img src="figuras/apontar.png" width="38"  border="0" style="position:absolute;right:120px;top:57px"></img> --->
						<div align="center"><label style="font-size:14px;font-family:Verdana, Arial, Helvetica, sans-serif">SELECIONE UMA AVALIAÇÃO</label><br>
						</div>
					</h1>
					
			</cfif>
			<cfset comItemEmRevisao=0>
			<cfif '#rsInspecoes.recordCount#' neq 0>

	            <div align="center" style="padding:10px;background:lavender; font-family:Verdana, Arial, Helvetica, sans-serif">
				
						<select name="selInspecoes" id="selInspecoes"  onchange="abrirInspecao(this.value)" style="width:500px">
							<option selected="selected" value="" ></option>
							
							<cfoutput query="rsInspecoes">
									<cfquery datasource="#dsn_inspecao#" name="rsInspecao">
										SELECT * FROM Inspecao 
										WHERE (INP_Situacao = 'NA' or INP_Situacao = 'ER')  and INP_NumInspecao='#rsInspecoes.INP_NumInspecao#'  
									</cfquery>
									<cfquery datasource="#dsn_inspecao#" name="rsCoordenador" >
										select Usu_Matricula, Usu_Apelido from usuarios where Usu_Matricula = Convert(varchar,#rsInspecao.INP_Coordenador#)
									</cfquery>
									<cfquery datasource="#dsn_inspecao#" name="rsUnidades">
										SELECT Und_Codigo, Und_Descricao, Und_NomeGerente FROM Unidades WHERE Und_Status='A' and Und_Codigo =#rsInspecao.INP_Unidade#
									</cfquery>
									<cfquery name="rsVerifComItemEmRevisao" datasource="#dsn_inspecao#">
										SELECT RIP_Resposta FROM Resultado_Inspecao 
										WHERE RIP_Recomendacao='S' AND RIP_NumInspecao='#rsInspecao.INP_NumInspecao#'
									</cfquery>
									
									<cfif '#comItemEmRevisao#' eq 0>
									   <cfset comItemEmRevisao='#rsVerifComItemEmRevisao.recordcount#'>
									</cfif>
																		
									<cfparam name="coordenador" default="#rsCoordenador.Usu_Matricula#">
											
								 <option  value="itens_inspetores_avaliacao.cfm?numInspecao=#INP_NumInspecao#&Unid=#rsUnidades.Und_Codigo#" style="<cfif rsVerifComItemEmRevisao.recordcount neq 0 >color:red</cfif>">
						     		#rsInspecao.INP_NumInspecao# - #trim(rsUnidades.Und_Descricao)# (#rsUnidades.Und_Codigo#) <cfif rsVerifComItemEmRevisao.recordcount neq 0 > - Reanálise: #rsVerifComItemEmRevisao.recordcount#<cfif #rsVerifComItemEmRevisao.recordcount# gt 1> itens<cfelse> item</cfif> </cfif>
							     </option>
								 						
							</cfoutput>
						</select>
						
						<cfif isdefined("coordenador") AND '#coordenador#' NEQ "" and isdefined("url.numInspecao") AND '#url.numInspecao#' NEQ "">
							<cfquery datasource="#dsn_inspecao#" name="rsInspecao2">
								SELECT * FROM Inspecao 
								WHERE (INP_Situacao = 'NA' or INP_Situacao = 'ER') and INP_NumInspecao=convert(varchar,'#url.numInspecao#'  )
							</cfquery>
							<cfquery datasource="#dsn_inspecao#" name="rsInspecoesFinalizada">
								SELECT * FROM Inspecao 
								 WHERE (INP_Situacao = 'NA' or INP_Situacao = 'ER') and  INP_NumInspecao = '#url.numInspecao#';
							</cfquery>
							<cfquery datasource="#dsn_inspecao#" name="rsCoordenador" >
								select Usu_Matricula, Usu_Apelido from usuarios where Usu_Matricula = Convert(varchar,#coordenador#)
							</cfquery>
							
							<cfquery datasource="#dsn_inspecao#" name="rsUnidades">
							<cfif isdefined('url.Unid')>
								SELECT Und_Codigo, Und_Descricao, Und_NomeGerente FROM Unidades WHERE Und_Status='A' and Und_Codigo =#url.Unid#
							<cfelse>
							    SELECT Und_Codigo, Und_Descricao, Und_NomeGerente FROM Unidades WHERE Und_Status='A' and Und_Codigo =#rsInspecao2.INP_Unidade#
							</cfif>
							
                            </cfquery>   
                             <cfif '#rsInspecoesFinalizada.recordCount#' neq  0>
									<div align="center" style="position:relative;top:10px;font-size:18px;color:#005782"><strong ><cfoutput>#url.numInspecao# - #trim(rsUnidades.Und_Descricao)# (#url.Unid#)</cfoutput></strong></div>
									<br>
									
									<cfquery datasource="#dsn_inspecao#" name="rsNumeraInspecao2">
										SELECT NIP_DtIniPrev FROM Numera_Inspecao WHERE NIP_NumInspecao=convert(varchar,'#url.NumInspecao#') AND NIP_Situacao='A'
									</cfquery>

									<cfquery datasource="#dsn_inspecao#" name="rsInspetorInspecao">
										SELECT IPT_MatricInspetor,Fun_Nome,INP_Coordenador,INP_Modalidade,Dir_Sigla,INP_DtFimInspecao,INP_DtInicDeslocamento,INP_DtFimDeslocamento,INP_DtInicInspecao FROM Inspetor_Inspecao 
										INNER JOIN Funcionarios on IPT_MatricInspetor=Fun_Matric
										INNER JOIN Diretoria ON  Dir_Codigo = Fun_DR 
										INNER JOIN Inspecao on IPT_NumInspecao = INP_NumInspecao
										WHERE IPT_NumInspecao=convert(varchar,'#url.NumInspecao#') 
										ORDER BY Fun_Nome ASC
									</cfquery>
								
									<cfquery datasource="#dsn_inspecao#" name="rsCoordenador2" >
										select Usu_Matricula, Usu_Apelido, Dir_Sigla from usuarios 
										INNER JOIN Diretoria ON  Dir_Codigo = Usu_DR 
										where Usu_Matricula = Convert(varchar,'#rsInspetorInspecao.INP_Coordenador#')
									</cfquery>
									<cfset dtIniPrev = dateformat("#rsNumeraInspecao2.NIP_DtIniPrev#",'dd/mm/yyyy')>
									
									<div align="left">
										<label style="font-size:12px;color:#005782" class="exibir">
											<cfoutput>
												Mod.: <cfif '#rsInspetorInspecao.INP_Modalidade#' eq 0>PRESENCIAL<cfelse>A DISTÂNCIA</cfif> - Coord.: #Trim(rsCoordenador2.Usu_Apelido)# (#Trim(rsCoordenador2.Dir_Sigla)#) - Data Prev.: #dtIniPrev#
											</cfoutput>
										</label>
										<br>
										<label style="font-size:12px;color:#005782" class="exibir">
											<cfoutput>Gerente da Unidade: #rsUnidades.Und_NomeGerente#</cfoutput>
							            </label>
									 <br><br>
<!--- <cfif ucase(trim(rsItem.INP_Situacao)) eq 'NA'> --->
									<label style="font-size:12px;color:#005782" class="form">
								<!--- <cfoutput> --->
									<div align="center"><a  href="cadastro_inspecao_inspetores_alt.cfm?
											numInspecao=<cfoutput>#url.NumInspecao#</cfoutput>
											&Unid=<cfoutput>#url.Unid#</cfoutput>											
											&coordenador=<cfoutput>#rsInspetorInspecao.INP_Coordenador#</cfoutput>
											&dtInicDeslocamento=<cfoutput>#DateFormat(rsInspetorInspecao.INP_DtInicDeslocamento,'dd/mm/yyyy')#</cfoutput>
											&dtFimDeslocamento=<cfoutput>#DateFormat(rsInspetorInspecao.INP_DtFimDeslocamento,'dd/mm/yyyy')#</cfoutput>
											&dtInicInspecao=<cfoutput>#DateFormat(rsInspetorInspecao.INP_DtInicInspecao,'dd/mm/yyyy')#</cfoutput>
											&dtFimInspecao=<cfoutput>#DateFormat(rsInspetorInspecao.INP_DtFimInspecao,'dd/mm/yyyy')#</cfoutput>
											&RIPMatricAvaliador=N
											##formCad" style="background-color:#CCCCCC"><strong class="titulo1">ALTERAR CADASTRO DE AVALIAÇÃO</strong></a></div>
									<!--- </cfoutput>  --->
									</label>
<!--- </cfif>	 --->								
				
										<!--- <br> --->
										<label style="font-size:12px;color:#005782;position:relative;top=15px" class="exibir">Inspetores:</label>
										<label style="font-size:12px;color:#005782;position:relative;left:90px" class="exibir">	
												<cfoutput query = "rsInspetorInspecao">
													<cfset maskmatrusu = left(IPT_MatricInspetor,1) & '.' & mid(IPT_MatricInspetor,2,3) & '.***-' & right(IPT_MatricInspetor,1)>													
													<br>#maskmatrusu# - #Fun_Nome# (#Trim(Dir_Sigla)#)
												</cfoutput>
										  </label>
								

									 <!---Início da barra de status--->
	 
									<cfif isdefined('url.Unid') and rsVerificaFinalizacao.recordcount neq 0>
									
										<cfquery datasource="#dsn_inspecao#" name="rsItensAvaliados">
												Select count(RIP_Resposta) as avaliados FROM Resultado_Inspecao
												Where RIP_NumInspecao = '#url.numInspecao#' and RIP_Resposta!='A' and (RIP_Recomendacao!='S' or RIP_Recomendacao is null)
										</cfquery>
										<cfquery datasource="#dsn_inspecao#" name="rsItensTotais">
												Select count(RIP_Resposta) as total FROM Resultado_Inspecao
												Where RIP_NumInspecao = '#url.numInspecao#'
										</cfquery>
										<cfif '#rsItensAvaliados.avaliados#' gt 0 >
										
											<cfset perc=round(('#rsItensAvaliados.avaliados#' / '#rsItensTotais.total#' )*100)>
												<cfif '#perc#' lt 1>
													<cfset perc='1%'>
														<cfelse>
															<cfset perc=round(('#rsItensAvaliados.avaliados#' / '#rsItensTotais.total#' )*100) & '%'>
												</cfif>
												<cfif '#perc#' gte 99.5 and '#perc#' lt 100>
													<cfset perc="99%">
												</cfif>
										</cfif>
										<cfoutput>
										<cfif '#rsItensAvaliados.avaliados#' gt 0 >
										
											<div align="center" style="background:red;width:'#perc#';height:5%;padding:2px;margin-top:10px">
												<div align="center" style="color:white;widht:720px;font-family:Verdana, Arial, Helvetica, sans-serif">#perc#</div>
											</div>
										</cfif>
										</cfoutput>
									</cfif>
									<!---Fim da barra de status--->
	                             </div>


							<cfelse>

								<cfquery datasource="#dsn_inspecao#" name="rsInspecoesFinalizada2">
									SELECT * FROM Inspecao 				
									WHERE INP_Situacao = 'CO' and INP_NumInspecao = '#url.numInspecao#'
								</cfquery>
								<cfquery datasource="#dsn_inspecao#" name="rsUnidade">
									SELECT Und_Codigo, Und_Descricao FROM Unidades WHERE Und_Codigo ='#rsInspecoesFinalizada2.INP_Unidade#'
								</cfquery>

								<div align="center" style="position:relative;top:10px;font-size:18px;color:#005782"><strong ><cfoutput>#url.numInspecao# - #trim(rsUnidade.Und_Descricao)# (#rsUnidade.Und_Codigo#)</cfoutput></strong></div>
								<br>
								<div align="center" style="position:relative;top:10px;font-size:16px;color:#005782"><strong >Todos os itens da Avaliação de Controle realizada na unidade foram executados com sucesso e foram submetidos à REVISÃO da SCOI.<BR>Os itens estarão liberados para visualização dos Inspetores Regionais e da unidade verificada após o término da revisão.</strong></div>
								<br><br>
							    <button onClick="window.close()" class="botao">Fechar</button> 
								
							</cfif>
						
						</cfif>

						
			   </div>
		   </cfif>

		</div>

<cfif isdefined("url.numInspecao")>
<!---Inspeções NA = não avaliadas, ER = em reavaliação, RA =reavaliado, CO = concluída--->
	<cfquery datasource="#dsn_inspecao#" name="rsInspecaoFinalizada">
		SELECT * FROM Inspecao 
		WHERE (Rtrim(INP_Situacao) = 'NA' or Rtrim(INP_Situacao) = 'ER') 
		and INP_NumInspecao = '#url.numInspecao#';
	</cfquery>
<cfif '#rsInspecaoFinalizada.recordCount#' neq  0>	

	<table id="tabelaItens" width="100%" class="exibir"  >
	

		<div align="center" class="titulosClaro"><cfoutput><div align="left">Qt. Itens: #rsItem.recordCount#</div></cfoutput></div>
		<cfif rsItem.recordCount neq 0>
 		<thead >
			<tr id="trItens" class="titulosClaro" title="Clique para classificar.">
				<th width="3%" bgcolor="eeeeee" class="exibir" onClick="sorting(tbodyItens, 0)" style="cursor:pointer">Ordem Priorização Execução<div><img id="classifCrescente0" src="Figuras/classifCrescente.png" width="20" style="display:none;visibility:hidden;cursor:pointer;margin-left:0px;position:relative;margin-top:0px"><img id="classifDecrescente0" src="Figuras/classifDecrescente.png" width="20" style="display:none;visibility:hidden;cursor:pointer;margin-left:0px;position:relative;margin-top:0px"></div></th>
				<th width="3%" bgcolor="eeeeee" class="exibir" onClick="sorting(tbodyItens, 1)" style="cursor:pointer">Status<div><img id="classifCrescente1" src="Figuras/classifCrescente.png" width="20" style="display:none;visibility:hidden;cursor:pointer;margin-left:0px;position:relative;margin-top:0px"><img id="classifDecrescente1" src="Figuras/classifDecrescente.png" width="20" style="display:none;visibility:hidden;cursor:pointer;margin-left:0px;position:relative;margin-top:0px"></div></th>
				<th width="10%" bgcolor="eeeeee" class="exibir" onClick="sorting(tbodyItens, 2)" style="cursor:pointer">Grupo<img id="classifCrescente2" src="Figuras/classifCrescente.png" width="20" style="display:none;visibility:hidden;cursor:pointer;margin-left:0px;position:relative;margin-top:0px"><img id="classifDecrescente2" src="Figuras/classifDecrescente.png" width="20" style="display:none;visibility:hidden;cursor:pointer;margin-left:0px;position:relative;margin-top:0px"></th>
				<th width="20%" bgcolor="eeeeee" class="exibir" >Item</th>
			</tr>
 		</thead>
 		<tbody id="tbodyItens">
			<cfoutput query="rsItem">

			<cfquery name="rsResultadoInspecao" datasource="#dsn_inspecao#">
				Select RIP_Resposta FROM Resultado_Inspecao where RIP_Unidade = '#RIP_Unidade#' AND RIP_NumInspecao = '#Rip_NumInspecao#' AND RIP_NumGrupo = #RIP_NumGrupo# AND RIP_NumItem = #RIP_NumItem#
			</cfquery>
				<cfset avaliacao = "#rsResultadoInspecao.RIP_Resposta#"> 
				<cfset aval = ""> 
				<cfswitch expression="#avaliacao#"> 
					<cfcase value="C"><cfset aval = "CONFORME"><cfset cor ="green"></cfcase>
					<cfcase value="N"><cfset aval = "NÃO CONFORME"><cfset cor ="red"></cfcase>
					<cfcase value="V"><cfset aval = "NÃO VERIFICADO"><cfset cor ="blue"></cfcase>
					<cfcase value="E"><cfset aval = "NÃO EXECUTA"><cfset cor ="cornflowerblue"></cfcase>
					<cfdefaultcase>
						<cfif trim('#RIP_MatricAvaliador#') eq '' AND '#avaliacao#' eq 'A'>
							<cfset aval = ""><cfset cor ="gray">
						</cfif>
						<cfif trim('#RIP_MatricAvaliador#') neq '' AND '#avaliacao#' eq 'A'>
							<cfset aval = ""><cfset cor ="black">
						</cfif>

					</cfdefaultcase> 
				</cfswitch>

				<tr id="#rsItem.CurrentRow#" bgcolor="f7f7f7" class="exibir"
					onMouseOver="mouseOver(this);" 
					onMouseOut="mouseOut(this);"
					onclick="gravaOrdLinha(this);capturaPosicaoScroll();window.open('itens_inspetores_avaliacao1_2024.cfm?Unid=#rsItem.RIP_Unidade#&Ninsp=#rsItem.Rip_NumInspecao#&Ngrup=#rsItem.RIP_NumGrupo#&Nitem=#rsItem.RIP_NumItem#&reop=#rsItem.RIP_CodReop#&SE=#rsItem.RIP_CodDiretoria#&numInspecao=#url.numInspecao#&pontuacaorip=#rsItem.TUI_Pontuacao#&tpunid=#rsItem.Und_TipoUnidade#&modal=#rsItem.INP_Modalidade#&frminspreincidente=#trim(rsItem.RIP_ReincInspecao)#&retornosn=""&frmsituantes=0&frmdescantes=""&itnreincidentes=#Itn_Reincidentes#','_self')"
					style="cursor:pointer;position:relative;">	
				<td width="2%"><div align="center">#rsItem.RankByPontuacao#</td>
				<td width="3%" bgcolor="#cor#"><div align="center" ><a onClick="capturaPosicaoScroll()" href="itens_inspetores_avaliacao1_2024.cfm?Unid=#rsItem.RIP_Unidade#&Ninsp=#rsItem.Rip_NumInspecao#&Ngrup=#rsItem.RIP_NumGrupo#&Nitem=#rsItem.RIP_NumItem#&reop=#rsItem.RIP_CodReop#&SE=#rsItem.RIP_CodDiretoria#&numInspecao=#url.numInspecao#&pontuacaorip=#rsItem.TUI_Pontuacao#&tpunid=#rsItem.Und_TipoUnidade#&modal=#rsItem.INP_Modalidade#&frminspreincidente=#trim(rsItem.RIP_ReincInspecao)#&retornosn=''&frmsituantes=0&frmdescantes=''&itnreincidentes=#Itn_Reincidentes#"  class="exibir"><cfif '#avaliacao#' eq 'A' and trim('#RIP_MatricAvaliador#') eq ''>NÃO AVALIADO</cfif><cfif '#avaliacao#' eq 'C'>CONFORME<br>(#RIP_MatricAvaliador#)</cfif><cfif '#avaliacao#' eq 'N'>NÃO CONFORME<br>(#RIP_MatricAvaliador#)</cfif><cfif '#avaliacao#' eq 'E'>NÃO EXECUTA<br>(#RIP_MatricAvaliador#)</cfif><cfif '#avaliacao#' eq 'V'>NÃO VERIFICADO<br>(#RIP_MatricAvaliador#)</cfif><cfif trim('#RIP_MatricAvaliador#') neq '' AND '#avaliacao#' eq 'A'>EM AVALIAÇÃO<BR>(#RIP_MatricAvaliador#)</cfif><cfif '#trim(rsItem.RIP_NCISEI)#' neq ''><span style="color:white"><br>com NCI</span></cfif><cfif #RIP_Recomendacao# eq 'S'><div style="color:white;margin-top:4px"><span style="background:darkred;padding:2px">REANÁLISE</span></div></cfif></a></div></td>
				<td width="10%"><div align="center">#rsItem.RIP_NumGrupo# - #rsItem.Grp_Descricao#</div></td>
				<td  width="20%"><div align="left" style="padding:10px"><cfif #rsItem.RIP_NumItem# le 9>0#rsItem.RIP_NumItem#<cfelse>#rsItem.RIP_NumItem#</cfif>-&nbsp;#rsItem.Itn_Descricao#</div></td>
				
				
			</cfoutput>
		</tbody>	
	</cfif>
	

		</table>
      
            <div align="center" style="position:relative;top:10px">
				<button onClick="window.close()" class="botao">Fechar</button>
				<!---Botão de validação para transmissão da Avaliação--->
					<cfif rsVerificaFinalizacao.recordcount eq 0>	
					  <cfif grpacesso eq "INSPETORES">
						<button style="margin-left:150px" onClick="document.frmopc.acao.value='liberaval';liberar();" class="botao">LIBERAR RELATÓRIO</button>
					  </cfif>	
					</cfif>	
				<!---Fim botão de validação para transmissão da Avaliação--->
			</div>
      

	</cfif>
	

	</div>
	<!--- Fim Área de conteúdo --->	 
	</td>
	</tr>

</table>
</cfif>
<input name="acao" type="hidden">
</form>


<cfinclude template="rodape.cfm">

</body>
</html>
<!---
 <cfcatch>
  <cfdump var="#cfcatch#">
</cfcatch>
</cftry> --->
