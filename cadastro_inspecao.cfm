<cfprocessingdirective pageEncoding ="utf-8">
<cfsetting requesttimeout="800">

   <cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	<cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
  </cfif>          
 
  <cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_DR, Usu_GrupoAcesso, Usu_Matricula, Usu_Email, Usu_Apelido, Usu_Coordena, Usu_Login 
	from usuarios 
	where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<cfif len(trim(qAcesso.Usu_email)) lte 0>
  <cflocation url="Alterar_permissao_rotinas_inspecao.cfm?svolta=cadastro_inspecao.cfm">
</cfif>

 <cfif '#trim(qAcesso.Usu_GrupoAcesso)#' neq "GESTORES" and '#trim(qAcesso.Usu_GrupoAcesso)#' neq "DESENVOLVEDORES">
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>      


<cfif trim(qAcesso.Usu_Coordena) neq ''>
    <cfset se= '#trim(qAcesso.Usu_Coordena)#'>
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
    <cfset se= '#trim(qAcesso.Usu_DR)#'>
</cfif>
  
  <cfif isdefined('url.acao')>		
	<cfif '#url.acao#' eq 'assumirevisao'>
		<cfquery datasource="#dsn_inspecao#">
			update Inspecao set INP_RevisorLogin = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
			WHERE INP_NumInspecao = '#url.numInspecao#'
		</cfquery>
	</cfif>

	<cfif '#url.acao#' eq 'excNumInsp'>
		<cfquery datasource="#dsn_inspecao#">
			DELETE FROM Inspetor_Inspecao WHERE IPT_NumInspecao=rtrim(ltrim(convert(varchar,'#url.numInspecao#'))) and
			IPT_CodUnidade=rtrim(ltrim('#url.unidade#'))
		</cfquery>

		<cfquery datasource="#dsn_inspecao#">
			DELETE FROM inspecao WHERE INP_NumInspecao=rtrim(ltrim(convert(varchar,'#url.numInspecao#'))) and
			INP_Unidade=rtrim(ltrim('#url.unidade#'))
		</cfquery>
		<cfquery datasource="#dsn_inspecao#">
           UPDATE Numera_Inspecao SET NIP_Situacao ='E', NIP_DtUltAtu=convert(char,	getdate(), 120), NIP_UserName=convert(varchar,'#qAcesso.Usu_Matricula#')
           WHERE NIP_NumInspecao=rtrim(ltrim(convert(varchar,'#url.numInspecao#'))) and NIP_Unidade=rtrim(ltrim('#url.unidade#'))
		</cfquery>
		<cflocation url = "cadastro_inspecao.cfm" addToken = "no">
	</cfif>
				
	<cfif '#url.acao#' eq 'excInsp'>
		<!---  Verifica se existe na inpeção itens com status diferente de 0 (em revisão) e 11(em liberação)	 --->
		<cfquery datasource="#dsn_inspecao#" name="qJaEncaminhada">
            SELECT Pos_Situacao_Resp FROM ParecerUnidade
			WHERE Pos_Inspecao = '#url.numInspecao#' 
		</cfquery>

		<cfif '#qJaEncaminhada.recordcount#' neq 0 and ('#qJaEncaminhada.Pos_Situacao_Resp#' neq 0 or  '#qJaEncaminhada.Pos_Situacao_Resp#' neq 11)>
		   <script>
		     alert('Esta verificação possui itens já liberados pelo gestor e encaminhados para o órgão responsável, portanto, não poderá ser excluída.');
			 window.open('cadastro_inspecao.cfm','_self');
		   </script>
		   <cfabort>
		</cfif>

		<cfquery datasource="#dsn_inspecao#">
			DELETE FROM Resultado_Inspecao WHERE RIP_NumInspecao=rtrim(ltrim(convert(varchar,'#url.numInspecao#'))) and
			RIP_Unidade=rtrim(ltrim('#url.unidade#'))
		</cfquery>

		<cfquery datasource="#dsn_inspecao#">
			DELETE FROM Inspetor_Inspecao WHERE IPT_NumInspecao=rtrim(ltrim(convert(varchar,'#url.numInspecao#'))) and
			IPT_CodUnidade=rtrim(ltrim('#url.unidade#'))
		</cfquery>

		<cfquery datasource="#dsn_inspecao#">
			DELETE FROM inspecao WHERE INP_NumInspecao=rtrim(ltrim(convert(varchar,'#url.numInspecao#'))) and
			INP_Unidade=rtrim(ltrim('#url.unidade#'))
		</cfquery>
		<cfquery datasource="#dsn_inspecao#">
           UPDATE Numera_Inspecao SET NIP_Situacao ='E', NIP_DtUltAtu=convert(char,	getdate(), 120),  NIP_UserName=convert(varchar,'#qAcesso.Usu_Matricula#')
           WHERE NIP_NumInspecao=rtrim(ltrim(convert(varchar,'#url.numInspecao#'))) and NIP_Unidade=rtrim(ltrim('#url.unidade#'))
		</cfquery>
        <cfquery datasource="#dsn_inspecao#">
			DELETE FROM Anexos WHERE Ane_NumInspecao=rtrim(ltrim(convert(varchar,'#url.numInspecao#'))) and
			Ane_Unidade=rtrim(ltrim('#url.unidade#'))
		</cfquery>

		<cflocation url = "cadastro_inspecao.cfm" addToken = "no">
	</cfif>
</cfif>

<cfquery datasource="#dsn_inspecao#" name="rsUnidades">
	SELECT Und_Codigo, Und_Descricao,Und_NomeGerente,Und_TipoUnidade FROM Unidades 
	WHERE Und_Status='A' and Und_CodDiretoria in(#se#)
	ORDER BY Und_Descricao ASC
</cfquery>

<cfquery datasource="#dsn_inspecao#" name="rsInspetores">
	SELECT Usu_Matricula, Usu_Apelido, Dir_Sigla FROM Usuarios 
	INNER JOIN Diretoria ON Dir_Codigo = Usu_DR
	INNER JOIN Funcionarios ON Fun_Matric = Usu_Matricula
	WHERE rtrim(Usu_GrupoAcesso)='INSPETORES' and Usu_DR in(#se#)
	ORDER BY Dir_Sigla, Usu_Apelido, Usu_DR
</cfquery>

<cfset nInsp =''>
<cfif isDefined("form.dataPrevista")>
	<cfparam name="URL.selModalidades" default="#form.selModalidades#">
	<cfparam name="URL.selUnidades" default="#form.selUnidades#">
	<cfparam name="URL.selCoordenador" default="#form.selCoordenador#">
	<cfparam name="URL.dataPrevista" default="#form.dataPrevista#">
	<cfparam name="URL.resp" default="#form.responsavel#">
	<cfparam name="URL.inpvalorprevisto" default="#form.inpvalorprevisto#">
	
    <cfset nInsp ='#left(trim("#form.selUnidades#"),2)#0001' & Year(Now())>
	

	<cfquery datasource="#dsn_inspecao#" name="rsNumProximaInspecao">
		SELECT MAX(cast(RIGHT(LEFT(ltrim(rtrim(NIP_NumInspecao)),6),4) as integer)) +1 as numInspecao FROM
		Numera_Inspecao
		WHERE RIGHT(ltrim(rtrim(NIP_NumInspecao)),4) = RIGHT('#URL.dataPrevista#',4) and
		left(ltrim(rtrim(NIP_NumInspecao)),2) = left(ltrim(rtrim('#form.selUnidades#')),2)
	</cfquery>
	<cfif '#rsNumProximaInspecao.numInspecao#' neq ''>
		<cfset nInsp="#left(trim('#form.selUnidades#'),2)#" & RepeatString(0,4-len('#rsNumProximaInspecao.numInspecao#'))
			& "#rsNumProximaInspecao.numInspecao#" & Year(#dataPrevista#)>
	</cfif>
	
	<cfif isdefined('url.acao')>
		<cfif '#url.acao#' eq 'cadNumInsp'>
			
			<cfset dia_data=Left('#dataPrevista#',2)>
			<cfset mes_data=Mid('#dataPrevista#',4,2)>
			<cfset ano_data=Right('#dataPrevista#',2)>
			<cfset dataPrevista=CreateDate(ano_data,mes_data,dia_data)>
			<cfset inpvalorprevisto = Replace(inpvalorprevisto,'.','','All')>
			<cfset inpvalorprevisto = Replace(inpvalorprevisto,',','.','All')>

			<cfquery datasource="#dsn_inspecao#" name="rsUnidadeSelecionadaItens">
				SELECT Und_Codigo, Und_Descricao, Und_TipoUnidade FROM Unidades WHERE Und_Status='A' and Und_Codigo ='#url.selUnidades#'
			</cfquery>
			<cfquery datasource="#dsn_inspecao#" name="rsItens">
				SELECT * FROM TipoUnidade_ItemVerificacao 
				WHERE TUI_Modalidade ='#selModalidades#' and TUI_Ano=year(#dataPrevista#) and 
				TUI_TipoUnid='#rsUnidadeSelecionadaItens.Und_TipoUnidade#' and TUI_Ativo=1
	        </cfquery>

			<cfif rsItens.recordcount neq 0> 
							<cfquery datasource="#dsn_inspecao#">
								INSERT INTO Numera_Inspecao
								(NIP_UNIDADE,NIP_NumInspecao,NIP_DtIniPrev,NIP_Situacao,NIP_DtUltAtu,NIP_UserName)
								VALUES
								('#selUnidades#','#nInsp#',<cfqueryparam value="#dataPrevista#" cfsqltype="CF_SQL_DATE">,'P',convert(char,getdate(), 120),'#qAcesso.Usu_Matricula#')
							</cfquery>

							<cfquery datasource="#dsn_inspecao#">
								INSERT INTO Inspecao
								(INP_Unidade,INP_NumInspecao,INP_HrsPreInspecao,INP_DtInicDeslocamento,INP_DtFimDeslocamento,INP_HrsDeslocamento,INP_DtInicInspecao,INP_DtFimInspecao,INP_HrsInspecao,INP_Situacao,INP_DtEncerramento,INP_Coordenador,INP_Responsavel,INP_DtUltAtu,INP_UserName,INP_Motivo,INP_Modalidade,INP_ValorPrevisto)
								VALUES
								('#selUnidades#','#nInsp#','0',<cfqueryparam value="#dataPrevista#" cfsqltype="CF_SQL_DATE">,<cfqueryparam value="#dataPrevista#" cfsqltype="CF_SQL_DATE">,'0',<cfqueryparam value="#dataPrevista#" cfsqltype="CF_SQL_DATE">,<cfqueryparam value="#dataPrevista#" cfsqltype="CF_SQL_DATE">,'0','NA',<cfqueryparam value="#dataPrevista#" cfsqltype="CF_SQL_DATE">,'#selCoordenador#','#resp#',convert(char,getdate(), 120),'#qAcesso.Usu_Login#','','#selModalidades#',#inpvalorprevisto#)
							</cfquery>
							<cfquery datasource="#dsn_inspecao#">
							   	UPDATE Unidades SET Und_NomeGerente = '#resp#' WHERE Und_Codigo ='#selUnidades#'
							</cfquery>
							<cflocation url = "cadastro_inspecao.cfm?acao=cadastrado&numInspecao=#nInsp#&selUnidades=#url.selUnidades#" addToken = "no">
			</cfif>	
		</cfif>
	</cfif>
<cfelse>
	<cfset nInsp =''>
	<cfparam name="URL.selModalidades" default="">
	<cfparam name="URL.selUnidades" default="">
	<cfparam name="URL.selCoordenador" default="">
	<cfparam name="URL.dataPrevista" default="">
	<cfparam name="URL.NumInspecao" default="">
	<cfparam name="URL.resp" default="">
	<cfparam name="URL.acao" default="">
	<cfparam name="URL.ANOATU" default="#year(now())#">
</cfif>

<cfquery datasource="#dsn_inspecao#" name="rsNumeraInspecao">
	SELECT Numera_Inspecao.*, LTRIM(RTRIM(Und_Descricao)) AS Und_Descricao, Und_Codigo, Dir_sigla FROM Numera_Inspecao
	LEFT JOIN Unidades ON Und_Codigo = NIP_Unidade
	LEFT JOIN Diretoria ON  Dir_Codigo = Und_CodDiretoria 
	WHERE Left(NIP_NumInspecao,2) in(#se#) AND NIP_Situacao='P' 
	ORDER BY Dir_sigla,Und_Descricao  
</cfquery>

<cfquery datasource="#dsn_inspecao#" name="rsUnidadesFiltradas">
	SELECT DISTINCT Dir_Sigla, RTRIM(LTRIM(Und_Descricao)) AS Und_Descricao, Und_NomeGerente, Und_Codigo 
	FROM Unidades 
	INNER JOIN Reops ON Und_CodReop = Rep_Codigo
	INNER JOIN Diretoria ON  Dir_Codigo = Und_CodDiretoria
	LEFT JOIN TipoUnidade_ItemVerificacao on TUI_TipoUnid = Und_TipoUnidade
	WHERE Und_Ano_Avaliar = '#URL.ANOATU#' and Und_Status='A' and Und_CodDiretoria in(#se#) and TUI_Ano = CONVERT(VARCHAR(4),year(getdate())) and TUI_Ativo=1
	      AND Und_Codigo not in(
			  SELECT INP_Unidade FROM Inspecao WHERE Left(INP_NumInspecao,2) in(#se#) AND INP_Situacao='NA'
			  )
	ORDER BY Dir_Sigla, Und_Descricao
</cfquery> 
<!---  --->

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	
<cfif '#url.acao#'eq "inspCad">
   <title>SNCI - INSPETORES CADASTRADOS NA AVALIAÇÕES <cfoutput>#url.numInspecao#</cfoutput></title>
<cfelse>
	<title>SNCI - CADASTRO DE AVALIAÇÕES</title>
 </cfif>

<link rel="stylesheet" type="text/css" href="view.css" media="all">


<body>


<script type="text/javascript">
						    
    //após o onload recupera a posição do scroll armazenada no sessionStorage e reposiciona-o conforme última localização
     window.onload = function() {
		var scrollposCadInsp = 0;
		if(sessionStorage.getItem('scrollposCadInsp')){
 			scrollposCadInsp = sessionStorage.getItem('scrollposCadInsp');
		}
        window.scrollTo(0, scrollposCadInsp);
		sessionStorage.setItem('scrollposCadInsp', '0');
		
    };

	//captura a posição do scroll (usado nos botões que chamam outras páginas)
    //e salva no sessionStorage

    function capturaPosicaoScroll(){
		if(sessionStorage.getItem('scrollposCadInsp')){
         sessionStorage.setItem('scrollposCadInsp', document.body.scrollTop);
		}
    }


//detecta se houve tecla pressionada
function keyPressed(evt){
    evt = evt || window.event;
    var key = evt.keyCode || evt.which;
    return String.fromCharCode(key); 
}

//se alguma tecla for pressionada , executa a função goload, reiniciando o tempo para load automático
document.onkeypress = function(evt) {
    var str = keyPressed(evt);
     goLoad();
};


var bd = document.getElementsByTagName('body')[0];
var time = new Date().getTime();
var ancora = window.location.href.split("#")[1];
//verifica se o mouse foi movimentado na tela e executa a função goload, reiniciando o tempo para load automático
bd.onmousemove = goLoad;

function goLoad() {	
    if(new Date().getTime() - time >= 90000) {
		// alert("Os dados da página serão atualizados!");
		time = new Date().getTime();
		aguarde();
		//o window.location = document.URL não funciona com âncoras
		//  setTimeout("window.location = document.URL;",1000);
		  setTimeout("window.location.reload(true);",1000);			
		
    }else{
        time = new Date().getTime();
    }
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
 function aguarde(t){

  if(t !== undefined){
	  topo = 30 + document.getElementById(t).offsetTop;
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

function infResponsavel(r){	
    aguarde('formCadNum');

	var url = <cfoutput>'cadastro_inspecao.cfm?selUnidades='+ r </cfoutput>;
	var newwindow = window.open(url,'_self');
}



function gerarData(str) {
		var partes = str.split("/");
		return new Date(partes[2], partes[1] - 1, partes[0]);
    }

	<cfoutput><cfparam name="URL.acao" default=""></cfoutput>
 function valida_formCadNum(a) {
	if (a == 'GERAR') {
		var frm = document.forms[0];

		if ((frm.inpvalorprevisto.value == '' || frm.inpvalorprevisto.value == '0,00') && $("#cbvlrprev").prop("checked") == false) {
			alert('Informe o Valor previsto!');
			frm.inpvalorprevisto.focus();
			return false;
		}

		if (frm.selUnidades.value == '') {
			alert('Informe a Unidade que será inspecionada!');
			frm.selUnidades.focus();
			return false;
		}

		if (frm.selModalidades.value == '') {
			alert('Informe a Modalidade desta Avaliação!');
			frm.selModalidades.focus();
			return false;
		}

		if (frm.selCoordenador.value == '') {
			alert('Informe o nome do Coordenador desta Avaliação!');
			frm.selCoordenador.focus();
			return false;
		}

		if (frm.dataPrevista.value == '') {
			alert('Informe a Data Prevista para Inicio desta Avaliação!');
			frm.dataPrevista.focus();
			return false;
		}

		var d = new Date();
		d.setHours(0,0,0,0);
		var datPrevInsp =gerarData(frm.dataPrevista.value);
		if(d > datPrevInsp){
			alert('A data prevista da Avaliação não pode ser menor que a data de hoje!');
			frm.dataPrevista.focus();
			frm.dataPrevista.select();
			return false;
		}

		function myTrim(x) {
		return x.replace(/^\s+|\s+$/gm,'');
		}
		var resp = myTrim(frm.responsavel.value);
		
		if (resp == '') {
			alert('Informe o nome do responsável pela Unidade selecionada.')
			frm.responsavel.focus();
			return false;
				
		}
			
		if(window.confirm("O nome do Responsável pela unidade está atualizado?\n\nConfirma o cadastro desta Avaliação?")){
			aguarde();
			if(sessionStorage.getItem('abaAtual')){
				sessionStorage.setItem('abaAtual', 'naoFinaliz');
			}
			
			return true;
		}else{
			return false;
		}
} else{return false;}
 }

//================
 function valida_formCadInsp() {
    
    if (frm.selInspetores.value == '') {
    	alert('Informe o nome do Inspetor!');
    	frm.selInspetores.focus();
    	return false;
    }
	
}
function moedadig(a){
		var valorinfo = $('#'+a).val()
		//alert('a: '+a)
		valorinfo = valorinfo.replace(",", "")
		let n = 0
		while (n == 0) {
			valorinfo = valorinfo.replace(".", "")
			if(valorinfo.indexOf('.') <= 0) {n = 1}
		}
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
//================
function Mascara_Data(data)
{
	switch (data.value.length)
	{
		case 2:
		   if (data.value < 1 || data.value > 31) {
		      alert('Valor para o dia inválido!');
			  data.value = '';
		      event.returnValue = false;
			  break;
		    } else {
			  data.value += "/";
				break;
			}
		case 5:
			if (data.value.substring(3,5) < 1 || data.value.substring(3,5) > 12) {
		      alert('Valor para o Mês inválido!');
			  data.value = '';
		      event.returnValue = false;
			  break;
		    } else {
			  data.value += "/";
				break;
			}
	}
}	
//================
function numericos() {
	var tecla = window.event.keyCode;
	//alert(tecla)
	//permite digitação das teclas numéricas (48 a 57, 96 a 105), Delete e Backspace (8 e 46), TAB (9) e ESC (27)	
		if (((tecla < 48) || (tecla > 57))) {
		//alert(tecla);
		event.returnValue = false;
	}
}
//================
function abrirPopup(url,w,h) {
var newW = w + 100;
var newH = h + 100;
var left = (screen.width-newW)/2;
var top = (screen.height-newH)/2;
var newwindow = window.open(url,'_blank', 'width='+newW+',height='+newH+',left='+left+',top='+top+ ',toolbar=no,location=no, directories=no, status=no, menubar=no, scrollbars=1, resizable=yes, copyhistory=no');
newwindow.resizeTo(newW, newH);
 
//posiciona o popup no centro da tela
newwindow.moveTo(left, top);
newwindow.focus();
return false;
}
//================
function abrirFormInspetores(insp,coord){
    var caminho = 'cadastro_inspecao_inspetores.cfm?acao=inspCad&numInspecao=' + insp +'&coordenador=' + coord;
  	abrirPopup(caminho,600,150);
	capturaPosicaoScroll();
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
 
//funções para pesquisa da unidade	   
function filterFunction() {
//    setTimeout('document.getElementById("selUnidades").focus();',1000);

  var input, filter, ul, li, a, i;
  input = document.getElementById("myInput");
  filter = input.value.toUpperCase();
  div = document.getElementById("selUnidades");
  a = div.document.getElementsByTagName("option");
  for (i = 0; i < a.length; i++) {	  
    txtValue = a[i].textContent || a[i].innerText;
    if (txtValue.toUpperCase().indexOf(filter) > -1 && filter!=null) {	 
	  a[i].selected=true;  
	  break;	 
    } else{
      a[i].selected=false;	
	  //div.remove(i);
	}
   }
   for (i = 0; i < a.length; i++) {	  
    txtValue = a[i].textContent || a[i].innerText;
    if (txtValue.toUpperCase().indexOf(filter) > -1) {	 
	  a[i].style.color= 'blue';
    } else{
	  a[i].style.color='#333';
	}
	if (filter == '') {
	  a[i].style.color='#333';
	}
   }
   document.getElementById("selCoordenador").innerText="";
   document.getElementById("selModalidades").innerText="";  
   document.getElementById("responsavel").innerText="";   
   document.getElementById("dataPrevista").innerText="";
   
}

function busca(){	
 sel=document.getElementById("selUnidades");
 sel.focus();
 infResponsavel(sel.value);
}

//Início do bloco de funções que controlam as linhas de uma tabela
	//remove a informação da linha clicada em uma tabela
	sessionStorage.removeItem('idLinha'); 
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
			linhaselecionadaAnterior = document.getElementById(sessionStorage.getItem('idLinha'));
			linhaselecionadaAnterior.style.backgroundColor = ''; 
			linhaselecionadaAnterior.style.color='#053c7e'; 
		}
		var linhaClicada = linha.id;       
		sessionStorage.setItem('idLinha', linhaClicada);						
		linha.style.backgroundColor='#053c7e';
		linha.style.color='#fff';
	}
	//Fim do bloco de funções que controlam as linhas de uma tabela	

	
</script>

</head>
<body id="main_body" style="<cfif '#url.acao#'eq 'inspCad'>background:white</cfif>" >
	

	<div align="center"></div>
	<a name="Inicio" id="Inicio"></a>
	<!--- <cfinclude template="cabecalho.cfm"> --->
	<br><br>
	<!--- <img id="top" src="top.png" alt=""> --->
<cfif '#url.acao#' neq "inspCad">	
<div id="aguarde" name="aguarde" align="center"  style="width:100%;height:200%;top:0px;left:0px; background:transparent;
filter:progid:DXImageTransform.Microsoft.gradient(startColorstr=#7F86b2ff,endColorstr=#7F86b2ff);
z-index:1000;visibility:hidden;position:absolute;" >		
		 <img id="imgAguarde" name="imgAguarde" src="figuras/aguarde.png" width="100px"  border="0" style="position:absolute;"></img>
</div>
	<div id="form_container" style="position:relative;top:-30px">
			
		<img src="figuras/cadastro.png" width="29"  border="0" style="position:absolute;left:-4px;top:-1px"></img>
		<h1 style="font-size:14px"><div align="center">GERAR E CADASTRAR N° DE AVALIAÇÃO</div></h1>
	
		<form id="formCadNum" nome="formCadNum" class="appnitro" onSubmit="return valida_formCadNum('')" enctype="multipart/form-data" method="post"  action="cadastro_inspecao.cfm?acao=cadNumInsp">
		
		    <input type="hidden" name="NumInspecao" value="<cfoutput>#url.numInspecao#</cfoutput>">
			<input type="hidden" name="sacao" id="sacao" value="">
			<cfif '#url.acao#' neq 'cadastrado' >

				<tr>
					<input type="text"  id="myInput" onChange="filterFunction();"  onkeyup="filterFunction();"  style="color:blue;padding-left:20px;text-align: left;border:1px solid #3bd1f3;margin-left:104px;position:absolute;top:40px;left:20px;width:200px">
					<img src="figuras/lupa.png" width="16"  border="0" style="position:absolute; left:126px;top:42px;z-index:1000"></img>
				</tr>
				<br>				
				<tr>
					<td>
						<label  for="selUnidades" style="color:grey">Unidade: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</label>
							<select name="selUnidades" id="selUnidades" class="form"  style="width:304px;display:inline-block;" onChange="infResponsavel(this.value)" >	
								
								<option selected="selected" value=""></option>
								<cfoutput query="rsUnidadesFiltradas" GROUP="Dir_Sigla"> 

								  <optgroup label="SE/#trim(Dir_Sigla)#"  >
								  <cfoutput>
				 					<cfquery name="rsAval" datasource="#dsn_inspecao#">		
										SELECT INP_NumInspecao
										FROM Inspecao
										WHERE INP_Unidade = '#Und_Codigo#' and Right(INP_NumInspecao,4) = '#URL.ANOATU#'
									</cfquery>								  
								  <cfif rsAval.recordcount lte 0>
									<option  <cfif '#url.selUnidades#' eq '#Und_Codigo#'>selected</cfif> value="#Und_Codigo#"><a>#trim(Dir_Sigla)# - #trim(Und_Descricao)# (#Und_Codigo#)</a></option>
								  </cfif> 
								  </cfoutput>
								   <optgroup label=""></optgroup>
								   </optgroup>
								  
								</cfoutput>
								
							</select>
							<a type="button"  onClick="busca();" href="#" class="botaoCad" style="padding:2px;margin-left:4px;position:relative;top:1px;">OK</a>                             
					</td>
				</tr>	

				<tr valign="baseline">
						<td colspan="3">&nbsp;&nbsp;</td>
				</tr>

                <tr>
					<td>
						

						<label for="selModalidades" style="color:grey">Modalidade:&nbsp;</label>

					   <cfif isdefined('url.selUnidades')>
	
							<cfquery datasource="#dsn_inspecao#" name="rsResp">
								SELECT Und_NomeGerente, Und_TipoUnidade FROM Unidades WHERE Und_Codigo = '#url.selUnidades#'
							</cfquery>
							
							<cfquery datasource="#dsn_inspecao#" name="rsModalidadesFiltradas">
								SELECT DISTINCT TUI_Modalidade FROM TipoUnidade_ItemVerificacao
								WHERE TUI_TipoUnid = '#rsResp.Und_TipoUnidade#' and TUI_Ano = CONVERT(VARCHAR(4),year(getdate())) and TUI_Ativo=1
							</cfquery>
                            <select name="selModalidades" id="selModalidades" class="form" style="position:relative;left:5px;width:110px">
								<option selected value=""></option>
								<cfoutput query="rsModalidadesFiltradas">
									<option value="#TUI_Modalidade#">
									<cfif #TUI_Modalidade# eq 0>PRESENCIAL<CFELSEIF #TUI_Modalidade# eq 1>A DISTÂNCIA<CFELSE>""</cfif></option>
								</cfoutput>
								
							</select>

						<cfelse>
                              <select name="selModalidades" id="selModalidades" class="form" style="position:relative;left:5px;width:110px">	
									<option value=""></option>
							   </select>
						</cfif>
						
					</td>
					
				</tr>

			    <div style="width:2px"></div>

				<tr>
					<td>
						<label for="selCoordenador" style="color:grey">Coordenador: </label>					
							<select name="selCoordenador" id="selCoordenador"class="form" style="width:340px">
								<option selected="selected" value=""></option>
								<cfoutput query="rsInspetores" GROUP="Dir_Sigla">
								 <optgroup label="SE/#trim(Dir_Sigla)#">
								 <cfoutput>
									<option value="#trim(Usu_Matricula)#">#trim(Dir_Sigla)# - #trim(Usu_Apelido)#</option>
							     </cfoutput>	
									<optgroup label=""></optgroup>
								 </optgroup>
								</cfoutput>
							</select>		
					</td>

					<td colspan="3">&nbsp;&nbsp;</td>

					<td>

						<label for="dataPrevista" style="color:grey">Data Prevista: </label>
						<input id="dataPrevista" name="dataPrevista" type="text"
									value="<cfoutput>#url.dataPrevista#</cfoutput>" style="width:110px" onKeyPress="numericos()"
									onKeyDown="Mascara_Data(this)" size="14" maxlength="10" />
					
					</td>

					<br>

					<td>
						<cfset resp = "">
						<cfif isdefined('url.selUnidades')>

							<cfquery datasource="#dsn_inspecao#" name="rsResp">
								SELECT Und_NomeGerente, Und_TipoUnidade FROM Unidades WHERE Und_Codigo = '#url.selUnidades#'
							</cfquery>

                             <cfset resp = trim('#rsResp.Und_NomeGerente#')>
						</cfif>

						<label for="responsavel" style="color:grey">Resp. Unid.: &nbsp;</label>
						<input id="responsavel" name="responsavel" 
						 type="text" value="<cfoutput>#resp#</cfoutput>" style="width:50%;text-align:left" size="30" maxlength="30" />
					
					</td>
				</tr>
				<br>
				<tr>
					<td>
						<label for="inpvalorprevisto" style="color:grey">Valor previsto R$: &nbsp;</label>
						<input name="inpvalorprevisto" id="inpvalorprevisto" type="text" value="" style="text-align:left" size="18" maxlength="18" onKeyPress="numericos()" onKeyUp="moedadig(this.name)">					
						<input type="checkbox" id="cbvlrprev" name="cbvlrprev" title="inativo"><label>Não se Aplica</label>
					</td>					
				</tr>
				<br><br>

				<tr>
					<div class="separador" style="margin-bottom:18px"></div>
				</tr>

				<div align="center" >
								    <!--- <img src="figuras/cadastro.png" width="20" border="0" style="position:relative;left:26px;top:2px"></img>
									<input name="btCadastrar" style="width:235px" type="submit" class="botao" id="btCadastrar" value="Gerar e cadastrar n° da Avaliação" align="center"> --->
									<a name="btCadastrar" onClick="return valida_formCadNum('GERAR')" id="btCadastrar" href="javascript:formCadNum.submit()"
									class="botaoCad" style="position:relative;left:13px;"><img src="figuras/cadastro.png" width="25"  border="0" style="position:absolute;left:0px;top:5px"></img>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Clique para Gerar e Cadastrar n° da Avaliação</a>
				</div>
				<br>
			</cfif>
				
			 <cfif '#url.acao#' eq 'cadastrado'>
				
			
			<div align="center">
					<tr>
						<img src="figuras/checkVerde.png" width="30"  border="0" style="position:absolute;left:75px;top:38px;"></img>
						<label style="color:#336699;font-size:20px">Número da Avaliação gerado e cadastrado com sucesso!</label>
					</tr>
					<br><br>
					<cfquery datasource="#dsn_inspecao#" name="rsUnidadeSelecionada">
						SELECT Und_Codigo, Und_Descricao, Und_TipoUnidade FROM Unidades WHERE Und_Status='A' and Und_Codigo ='#url.selUnidades#'
					</cfquery>
					<label style="color:#336699;font-size:18px"><cfoutput>#trim(rsUnidadeSelecionada.Und_Descricao)# (#trim(rsUnidadeSelecionada.Und_Codigo)#)</cfoutput></label>	
					<br><br>
					<tr>
						<label style="color:grey">N° da Avaliação: </label><label style="color:#336699">
							<cfoutput><strong>#url.numInspecao#</strong></cfoutput>
						</label>
						<cfquery datasource="#dsn_inspecao#" name="rsModalidade">
						  SELECT INP_Modalidade FROM Inspecao WHERE INP_NumInspecao = convert(varchar,'#url.numInspecao#')
						</cfquery>
						<label style="color:grey">- Modalidade: </label><label style="color:#336699">
							<cfoutput><cfif #rsModalidade.INP_Modalidade# eq 0>PRESENCIAL<CFELSE>A DISTÂNCIA</CFIF></cfoutput>	
							</label>

					</tr>
				
				</div>
				<br>
			
		    <tr>
			    <div align="center">
					<td>
							<!--- <img src="figuras/cadastro.png" width="20" border="0" style="position:relative;left:26px;top:2px"></img>
							<input name="button" type="button" style="width:170px" class="botao" onClick="window.open('cadastro_inspecao.cfm','_self')" value="Gerar Outra Avaliação"> --->
							<a name="btCadastrar" onClick="aguarde();window.open('cadastro_inspecao.cfm','_self')" id="btCadastrar" href="#"
							class="botaoCad" style="position:relative;"><img src="figuras/cadastro.png" width="25"  border="0" 
							style="position:absolute;left:0px;top:5px"></img>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Gerar Outro N° de Avaliação</a>
					</td>
			    </div>
			</tr>
			<tr>
				<div align="center">
				   <label style="color:red;position:relative;top:15px;font-size:12px">Obs.:Na tabela abaixo, clique no ícone <img src="figuras/usuario.png" alt="Clique para visualizar os inspetores desta Avaliação" width="20" height="20" border="0"  style="position:relative;top:3px"></img> para cadastrar a equipe de Avaliação e finalizar este cadastro.</label>
				</div>
			</tr>
		</form>
		
	</cfif>

	</div>
	

<style>



.tablink {
  background-color: #555;
  color: white;
  float: center;
  outline: none;
  cursor: pointer;
  padding: 5px;
  font-size: 12px;
  width: 140px;
  border:none;

}

.tablink:hover{
	background-color:#fff!important;
	color:#000;
	
}

.tabcontent {
  color: white;
  display: none;
  padding:10px;
  width: 720px;
}

.divTabela {
	overflow-y: scroll;
	overflow-x: hidden;
}

thead tr {
	position: relative;
	top: expression(this.offsetParent.scrollTop);
	z-index: 1000;
}

tbody {
	height: auto;
}
</style>
<cfquery datasource="#dsn_inspecao#" name="rsNaoIniciadas">
				SELECT INP_DTConcluirAvaliacao, INP_NumInspecao, INP_Coordenador, INP_DtInicInspecao, INP_DtFimInspecao, INP_Unidade, INP_Modalidade,INP_RevisorLogin,NIP_NumInspecao, LTRIM(RTRIM(Und_Descricao)) AS Und_Descricao, Und_Codigo, Dir_Sigla  
				FROM  Inspecao
				INNER JOIN Numera_Inspecao ON INP_NumInspecao = NIP_NumInspecao
				INNER JOIN Unidades ON Und_Codigo = INP_Unidade
				INNER JOIN Diretoria ON  Dir_Codigo = Und_CodDiretoria
				WHERE  Und_CodDiretoria in(#se#)  and INP_Situacao ='NA' and NIP_Situacao = 'A' and INP_AvaliacaoAtiva is NUll
				ORDER BY INP_NumInspecao,INP_DtInicInspecao
</cfquery>
<cfquery datasource="#dsn_inspecao#" name="rsInspecao">
				SELECT distinct INP_DTConcluirAvaliacao, INP_NumInspecao, INP_Coordenador, INP_DtInicInspecao, INP_DtFimInspecao, INP_Unidade, INP_Modalidade,INP_RevisorLogin,NIP_NumInspecao, LTRIM(RTRIM(Und_Descricao)) AS Und_Descricao, Und_Codigo, Dir_Sigla  
				FROM  Inspecao
				INNER JOIN Numera_Inspecao ON INP_NumInspecao = NIP_NumInspecao
				INNER JOIN Unidades ON Und_Codigo = INP_Unidade
				INNER JOIN Diretoria ON  Dir_Codigo = Und_CodDiretoria
				WHERE  Und_CodDiretoria in(#se#)  and INP_Situacao ='NA' and NIP_Situacao = 'A' and INP_AvaliacaoAtiva = 'S'
				ORDER BY INP_NumInspecao,INP_DtInicInspecao
</cfquery>

<!---Inspeções NA = não avaliadas, ER = em reavaliação, RA =reavaliado, CO = concluída--->
<cfquery datasource="#dsn_inspecao#" name="rsEmRevisao">
				SELECT distinct INP_DTConcluir_Despesas, INP_DTConcluirAvaliacao, INP_NumInspecao, INP_DtFimInspecao, INP_Unidade,INP_Coordenador, INP_DtEncerramento,INP_DtUltAtu,INP_Modalidade,LTRIM(RTRIM(Und_Descricao)) AS Und_Descricao, Und_Codigo, Dir_sigla, Pro_Situacao, 'comNC' as tipo FROM  Inspecao
				LEFT JOIN ParecerUnidade ON Pos_Inspecao = INP_NumInspecao
				LEFT JOIN ProcessoParecerUnidade ON Pro_Inspecao = INP_NumInspecao
				LEFT JOIN Unidades ON Und_Codigo = INP_Unidade
				LEFT JOIN Diretoria ON  Dir_Codigo = Und_CodDiretoria
				WHERE  Und_CodDiretoria in(#se#)  
				and right(INP_NumInspecao,4) = CONVERT(VARCHAR(4),year(getdate())) 
				and (POS_SITUACAO_RESP in(0,11) or rtrim(INP_Situacao) ='ER' or rtrim(INP_Situacao) ='RA')  
				ORDER BY INP_NumInspecao, INP_DtEncerramento
</cfquery>

<cfquery datasource="#dsn_inspecao#" name="rsFinalizadasSemNC" >
			SELECT INP_DTConcluir_Despesas, INP_DTConcluirAvaliacao, INP_NumInspecao, INP_DtFimInspecao, INP_Unidade,INP_Coordenador, INP_DtEncerramento,INP_DtUltAtu,INP_Modalidade
				, LTRIM(RTRIM(Und_Descricao)) AS Und_Descricao, Und_Codigo, Dir_sigla, Pro_Situacao, 'semNC' as tipo FROM  Inspecao
			LEFT JOIN ParecerUnidade ON Pos_Inspecao = INP_NumInspecao 
			LEFT JOIN ProcessoParecerUnidade ON Pro_Inspecao = INP_NumInspecao
			LEFT JOIN Unidades ON Und_Codigo = INP_Unidade
			LEFT JOIN Diretoria ON  Dir_Codigo = Und_CodDiretoria
			WHERE  Und_CodDiretoria in(#se#) 
			and POS_SITUACAO_RESP IS NULL 
			and INP_Situacao = 'CO'
			and right(INP_NumInspecao,4) = CONVERT(VARCHAR(4),year(getdate())) 
			ORDER BY INP_NumInspecao
</cfquery>

<cfquery datasource="#dsn_inspecao#" name="rsFinalizadasSemNCencerrado">
			SELECT INP_DTConcluirAvaliacao, INP_NumInspecao, INP_DtFimInspecao, INP_Unidade,INP_Coordenador, INP_DtEncerramento,INP_DtUltAtu,INP_Modalidade,INP_RevisorLogin,LTRIM(RTRIM(Und_Descricao)) AS Und_Descricao, Und_Codigo, Dir_sigla, Pro_Situacao 
			FROM  Inspecao
			LEFT JOIN ParecerUnidade ON Pos_Inspecao = INP_NumInspecao 
			LEFT JOIN ProcessoParecerUnidade ON Pro_Inspecao = INP_NumInspecao
			LEFT JOIN Unidades ON Und_Codigo = INP_Unidade
			LEFT JOIN Diretoria ON  Dir_Codigo = Und_CodDiretoria
			WHERE  Und_CodDiretoria in(#se#) 
			and POS_SITUACAO_RESP IS NULL 
			and INP_Situacao = 'CO'
			and Pro_Situacao = 'EN'
			and right(INP_NumInspecao,4) = CONVERT(VARCHAR(4),year(getdate())) 
			ORDER BY INP_NumInspecao
</cfquery>

<cfquery dbtype="query" name="rsEmRevisaoFinalizadasSemNC" >
  SELECT * FROM rsEmRevisao UNION SELECT * FROM rsFinalizadasSemNC WHERE Pro_Situacao = 'AB' and INP_DTConcluirAvaliacao IS NOT NULL
</cfquery>

<cfquery datasource="#dsn_inspecao#" name="rsvlralocado">
	SELECT distinct INP_NumInspecao,INP_Unidade,LTRIM(RTRIM(Und_Descricao)) AS Und_Descricao,INP_Modalidade,INP_DTConcluirAvaliacao,Dir_sigla,INP_RevisorLogin,Usu_Apelido
	FROM  Inspecao
	INNER JOIN Unidades ON Und_Codigo = INP_Unidade
	INNER JOIN Diretoria ON  Dir_Codigo = Und_CodDiretoria
	LEFT JOIN Usuarios ON INP_RevisorLogin = Usu_Login
	WHERE  Und_CodDiretoria in(#se#) 
	and right(INP_NumInspecao,4) = CONVERT(VARCHAR(4),year(getdate())) 
	and INP_DTConcluirAvaliacao is not null
	and INP_DTConcluir_Despesas is null
	ORDER BY Dir_sigla,INP_NumInspecao
</cfquery>

<cfset totalSemValidacao = 0>
<cfoutput query="rsFinalizadasSemNC">
	<cfquery datasource="#dsn_inspecao#" name="rsSemValidacao" >
		SELECT Count(RIP_NumInspecao) as total, Count(CASE WHEN RIP_Recomendacao='V' THEN 1 END) AS validado  FROM Resultado_Inspecao
		WHERE RIP_NumInspecao = '#INP_NumInspecao#'
	</cfquery>
    <cfif "#rsSemValidacao.total#" neq "#rsSemValidacao.validado#"  and "#rsSemValidacao.total#" neq 0>
      <cfset totalSemValidacao = '#totalSemValidacao#' + 1>
    </cfif>
</cfoutput>


<cfquery datasource="#dsn_inspecao#" name="rsExcluidas" >
	SELECT NIP_UserName, NIP_DtIniPrev, NIP_DtUltAtu, NIP_NumInspecao, LTRIM(RTRIM(Und_Descricao)) AS Und_Descricao, Und_Codigo, Dir_sigla FROM  Numera_Inspecao
	LEFT JOIN Unidades ON Und_Codigo = NIP_Unidade
	LEFT JOIN Diretoria ON  Dir_Codigo = Und_CodDiretoria
	WHERE  Und_CodDiretoria in(#se#) and NIP_Situacao = 'E' and right(NIP_NumInspecao,4) = CONVERT(VARCHAR(4),year(getdate())) 
	ORDER BY NIP_NumInspecao  
</cfquery>
<h1 id="titulo" style="font-size:14px;width:100%;"><STRONG>AVALIAÇÕES</STRONG></h1>

<div style="background:#6699CC;width=720px;">
	<button class="tablink" onmouseOver="corHover(this);" onMouseOut="corOut(this);" onClick="openPage('NaoFinalizadas', this, '#6699CC')" id="naoFinaliz"><STRONG>INCLUIR INSPETORES</STRONG><br>( <cfoutput>#rsNumeraInspecao.recordcount#</cfoutput> )</button>
	<button class="tablink" onmouseOver="corHover(this);" onMouseOut="corOut(this);" onClick="openPage('NaoIniciadas', this, '#6699CC')" id="naoAval"><STRONG>NÃO INICIADAS</STRONG><br>( <cfoutput>#rsNaoIniciadas.recordcount#</cfoutput> )</button>
	<button class="tablink" onmouseOver="corHover(this);" onMouseOut="corOut(this);" onClick="openPage('EmANDAMENTO', this, '#6699CC')" id="emAndam"><STRONG>EM ANDAMENTO</STRONG><br>( <cfoutput>#rsInspecao.recordcount#</cfoutput> )</button>
	<button class="tablink" onmouseOver="corHover(this);" onMouseOut="corOut(this);" onClick="openPage('EmRevisao', this, '#6699CC')" id="emRev"><STRONG>EM REVISÃO</STRONG><br>( <cfoutput>#rsEmRevisaoFinalizadasSemNC.recordcount#</cfoutput> )</button>
	<button class="tablink" onmouseOver="corHover(this);" onMouseOut="corOut(this);" onClick="openPage('VlrAloc', this, '#6699CC')" id="vAloc"><STRONG>VALORES ALOCADOS</STRONG><br>( <cfoutput>#rsvlralocado.recordcount#</cfoutput> )</button>
	<button class="tablink" onmouseOver="corHover(this);" onMouseOut="corOut(this);" onClick="openPage('SemNC', this, '#6699CC')" id="sNC"><STRONG>SEM ITEM NC</STRONG><br>( <cfoutput>#rsFinalizadasSemNCencerrado.recordcount#</cfoutput> )</button>
    <button class="tablink" onmouseOver="corHover(this);" onMouseOut="corOut(this);" onClick="openPage('Excluidas', this, '#6699CC')" id="excl"><STRONG>EXCLUÍDAS</STRONG><br>( <cfoutput>#rsExcluidas.recordcount#</cfoutput> )</button>

		<div id="NaoFinalizadas" class="tabcontent" >
			<!---INICIO TABELA DE AVALIAÇÕES COM NUMERAÇÃO CADASTRADA, PORÉM, SEM CADASTRO CONCLUÝDO--->
			<cfif rsNumeraInspecao.recordCount neq 0>
				<div  id="form_container" style="width:680px;height:expression(this.scrollHeight>299?'300px':'auto');overflow-y:auto;">
					<table  border="0" align="center"  id="tabInspecao" style="width:expression(this.scrollHeight>299?'683px':'700px');">  
						<tr>
							<td colspan="7" align="center" class="titulos" ><h1 style="font-size:14px;background:#6699CC">AVALIAÇÕES COM NUMERAÇÃO CADASTRADA (com cadastro não finalizado)</h1></td>
						</tr>
						
						<tr bgcolor="#6699CC" class="exibir" align="center" style="color:#fff">

							<td width="5%">
								<div align="center">Número</div>
							</td>
							<td width="35%">
								<div align="center">Unidade</div>
							</td>
							<td width="5%">
								<div align="center">Mod.</div>
							</td>
							<td width="40%">
								<div align="center">Coordenador</div>
							</td>
				
							<td width="5%">
								<div align="center">Data Prev.</div>
							</td>
							<td width="5%">
								<div align="center">Inspetores</div>
							</td>
							<td width="5%">
								<div align="center">Excluir</div>
							</td>
						</tr> 
					
						<cfset scor = 'white'>
						<cfoutput query="rsNumeraInspecao">
							
							<cfquery datasource="#dsn_inspecao#" name="rsModalidadeTable">
								SELECT INP_Modalidade, INP_Coordenador FROM Inspecao WHERE INP_NumInspecao = convert(varchar,'#NIP_NumInspecao#')
							</cfquery>
							<cfquery datasource="#dsn_inspecao#" name="rsInspetorTable">
								SELECT Fun_Matric, Fun_Nome, Dir_Sigla FROM Funcionarios 
								INNER JOIN Diretoria ON  Dir_Codigo = Fun_DR
								WHERE Fun_Matric ='#rsModalidadeTable.INP_Coordenador#'
							</cfquery>
							<cfset perInspec = '#DateFormat(NIP_DtIniPrev,'dd/mm/yyyy')#'>
							
							<form  id="formNaoFinalizadas" action="" method="POST" >

								<tr id="#rsNumeraInspecao.CurrentRow#" valign="middle" bgcolor="#scor#"  class="exibir"
									onMouseOver="mouseOver(this);" 
                                    onMouseOut="mouseOut(this);"
                                    onclick="gravaOrdLinha(this);">
									
									<td width="5%">
										<div align="center">#NIP_NumInspecao#</div>
									</td>
									<td width="35%">
										<div align="left">#trim(Dir_Sigla)#-#trim(Und_Descricao)#</div>
									</td>
									<td width="5%">
										<div align="center"><cfif #rsModalidadeTable.INP_Modalidade# eq 0>PRES.<CFELSE>A DIST.</CFIF></div>
									</td>
									<td width="40%">
										<div align="left">#trim(rsInspetorTable.Fun_Nome)# (#trim(rsInspetorTable.Fun_Matric)#-#trim(rsInspetorTable.Dir_Sigla)#)</div>
										<!--- <div align="center"><cfif '#rsModalidadeTable.INP_Modalidade#' eq '0'>PRESENCIAL<cfelse>A DISTÂNCIA</cfif></div> --->
									</td>
						
									<td width="5%">
										<div align="left">#perInspec#</div>
									</td>
									<cfquery datasource="#dsn_inspecao#" name="rsInspCaInsp">
										SELECT * FROM Inspecao 
										WHERE  Left(INP_NumInspecao,2) in(#se#) 
											and INP_NumInspecao = '#NIP_NumInspecao#'
											and INP_Situacao ='NA' 
									</cfquery>
									<td width="5%" height="25px">
										<div align="center"><a href="cadastro_inspecao_inspetores.cfm?
											numInspecao=#rsInspCaInsp.INP_NumInspecao#
											&coordenador=#rsInspCaInsp.INP_Coordenador#
											&dtInicDeslocamento=#DateFormat(rsInspCaInsp.INP_DtInicDeslocamento,'dd/mm/yyyy')#
											&dtFimDeslocamento=#DateFormat(rsInspCaInsp.INP_DtFimDeslocamento,'dd/mm/yyyy')#
											&dtInicInspecao=#DateFormat(rsInspCaInsp.INP_DtInicInspecao,'dd/mm/yyyy')#
											&dtFimInspecao=#DateFormat(rsInspCaInsp.INP_DtFimInspecao,'dd/mm/yyyy')#
											##formCad"><img src="figuras/usuario.png" alt="Clique para cadastrar/visualizar inspetores" width="20" height="20" border="0" ></a></div>
									</td>

									<td width="5%">
										<div align="center"><a onClick="return confExc('NaoFinalizadas','Confirma a exclusão desta Avaliação? \n#trim(NIP_NumInspecao)#-#trim(Und_Descricao)#(#trim(Und_Codigo)#)');" href="cadastro_inspecao.cfm?acao=excNumInsp&numInspecao=#NIP_NumInspecao#&unidade=#NIP_Unidade#"><img src="icones/lixeiraRosa.png" alt="Clique para excluir este cadastro" width="17" height="17" border="0" ></a></div>
									</td>
								</tr>
							</form>
					
							<cfif scor eq 'white'>
								<cfset scor = 'f7f7f7'>
							<cfelse>
								<cfset scor = 'white'>
							</cfif>
						</cfoutput>
					</table>
				</div>
			<cfelse>
			<label>NÃO EXISTEM AVALIAÇÕES COM CADASTRO NÃO FINALIZADO</label>
			</cfif>
			<!---FIM TABELA DE AVALIAÇÕES COM NUMERAÇÃO CADASTRADA, PORÉM, SEM CADASTRO CONCLUÝDO--->
		</div>

		<div id="NaoIniciadas" class="tabcontent">
			<!---INICIO TABELA DE AVALIAÇÕES COM CADASTRO CONCLUÍDO, POREM, NÃO AVALIADAS--->
			<cfif rsNaoIniciadas.recordCount gt 0>
				<div id="form_container" name="divInsp" style="width:900px;height:expression(this.scrollHeight>299?'300px':'auto');overflow-y:auto;">
					<table border="0" align="center"  id="tabInsp" style="width:expression(this.scrollHeight>299?'683px':'700px');">
						<tr>
							<td colspan="7" align="center" class="titulos"><h1 style="font-size:14px;background:#6699CC">AVALIAÇÕES COM CADASTRO FINALIZADO (Avaliações não Iniciadas)</h1></td>
						</tr>
						
						<tr bgcolor="#6699CC" class="exibir" align="center" style="color:#fff">
							<td width="5%">
								<div align="center">Número</div>
							</td>
							<td width="25%">
								<div align="center">Unidade</div>
							</td>
							<td width="7%">
									<div align="center">Mod.</div>
							</td>

							<td width="10%">
								<div align="center">Período Previsto</div>
							</td>

							<td width="5%">
								<div align="center">Inspetores</div>
							</td>
							<td width="5%">
								<div align="center">Excluir</div>
							</td>

						</tr>
						
					
						<cfset scor = 'white'>
						<cfset avaliada = 0>
						<cfoutput query="rsNaoIniciadas">
								<cfquery datasource="#dsn_inspecao#" name="rsItensTotais" >
									Select count(RIP_Resposta) as total FROM Resultado_Inspecao
									Where RIP_NumInspecao = '#rsNaoIniciadas.INP_NumInspecao#'
								</cfquery>
								<cfquery datasource="#dsn_inspecao#" name="rsItemNCI" >
									Select RIP_NCISEI FROM Resultado_Inspecao
									Where RIP_NumInspecao = '#rsNaoIniciadas.INP_NumInspecao#' and Rtrim(Ltrim(RIP_NCISEI)) !=''
								</cfquery>
							
								<cfquery datasource="#dsn_inspecao#" name="rsEmReavaliacao" >
									Select RIP_Resposta, RIP_Recomendacao FROM Resultado_Inspecao
									Where RIP_NumInspecao = '#rsNaoIniciadas.INP_NumInspecao#' and RIP_Recomendacao ='S'
								</cfquery>
								
								<cfquery datasource="#dsn_inspecao#" name="rsReavaliado" >
									Select RIP_Resposta, RIP_Recomendacao FROM Resultado_Inspecao
									Where RIP_NumInspecao = '#rsNaoIniciadas.INP_NumInspecao#' and RIP_Recomendacao ='R' 
								</cfquery>

							
								<cfquery datasource="#dsn_inspecao#" name="rsInspetorTable2">
									SELECT Fun_Matric, Fun_Nome, Dir_Sigla FROM Funcionarios 
									INNER JOIN Diretoria ON  Dir_Codigo = Fun_DR
									WHERE Fun_Matric =#rsNaoIniciadas.INP_Coordenador#
								</cfquery>
								<cfset perInspec='#DateFormat(rsNaoIniciadas.INP_DtInicInspecao,"dd/mm/yyyy")#' & ' a ' & '#DateFormat(rsNaoIniciadas.INP_DtFimInspecao,"dd/mm/yyyy")#'>
							<form action="" method="POST">

									<tr id="#rsNaoIniciadas.CurrentRow#" valign="middle" bgcolor="#scor#" class="exibir"
										onMouseOver="mouseOver(this);" 
										onMouseOut="mouseOut(this);"
										onclick="gravaOrdLinha(this);"
										style="cursor:pointer">
												<td width="5%" onClick="capturaPosicaoScroll();window.open('itens_inspetores_avaliacao.cfm?numInspecao=#INP_NumInspecao#&Unid=#INP_Unidade#','_blank');">
													<div align="left">
														#INP_NumInspecao#
													</div>
												</td>

												<cfset perc='0%'>
												<td width="25%"  onclick="capturaPosicaoScroll();window.open('itens_inspetores_avaliacao.cfm?numInspecao=#INP_NumInspecao#&Unid=#INP_Unidade#','_blank');">
															#trim(Dir_Sigla)#-#trim(Und_Descricao)#						
												</td>

												<td width="7%" onClick="capturaPosicaoScroll();window.open('itens_inspetores_avaliacao.cfm?numInspecao=#INP_NumInspecao#&Unid=#INP_Unidade#','_blank');">
													<div align="center">
														<cfif #INP_Modalidade# eq 0>PRES.<CFELSE>A DIST.</CFIF>
													</div>
												</td>
												<td width="10%" onClick="capturaPosicaoScroll();window.open('itens_inspetores_avaliacao.cfm?numInspecao=#INP_NumInspecao#&Unid=#INP_Unidade#','_blank');">
													<div align="center">#perInspec#</div>
												</td>
												
												
												<cfquery datasource="#dsn_inspecao#" name="rsInspCaInsp">
													SELECT * FROM Inspecao
													WHERE INP_NumInspecao = '#NIP_NumInspecao#'
												</cfquery>
										
									<td width="5%" height="25px">	
												<div align="center">
										<a href="cadastro_inspecao_inspetores_alt.cfm?
										numInspecao=#rsInspCaInsp.INP_NumInspecao#
										&Unid=#rsInspCaInsp.INP_Unidade#
										&coordenador=#rsInspCaInsp.INP_Coordenador#
										&dtInicDeslocamento=#DateFormat(rsInspCaInsp.INP_DtInicDeslocamento,'dd/mm/yyyy')#
										&dtFimDeslocamento=#DateFormat(rsInspCaInsp.INP_DtFimDeslocamento,'dd/mm/yyyy')#
										&dtInicInspecao=#DateFormat(rsInspCaInsp.INP_DtInicInspecao,'dd/mm/yyyy')#
										&dtFimInspecao=#DateFormat(rsInspCaInsp.INP_DtFimInspecao,'dd/mm/yyyy')#
										&RIPMatricAvaliador=N
										&telaretorno=cadastro_inspecao.cfm
										##formCad"><img src="figuras/usuario.png" alt="Clique para cadastrar/visualizar inspetores" width="20" height="20" border="0" ></a>													
										</div>
									</td>														
												<td width="5%" height="25px">
														<div align="center"><a
																onclick="return confExc('NaoAvaliadas','Confirma a exclusão desta Avaliação? \n#trim(rsNaoIniciadas.INP_NumInspecao)#-#trim(Und_Descricao)#(#trim(Und_Codigo)#)')"
																href="cadastro_inspecao.cfm?acao=excInsp&numInspecao=#rsNaoIniciadas.INP_NumInspecao#&unidade=#Und_Codigo#"><img
																	src="icones/lixeiraRosa.png" alt="Clique para excluir esta Avaliação"
																	width="17" height="17" border="0"></img></a>
														</div>
												</td>
									</tr>

							</form>

							<cfif scor eq 'white'>
								<cfset scor = 'f7f7f7'>
							<cfelse>
								<cfset scor = 'white'>
							</cfif>
						</cfoutput>


					</table>
				</div>
			<cfelse>
				<label>NÃO EXISTEM AVALIAÇÕES NÃO INICIADAS </label>
			</cfif>
			
		</div>

		<div id="EmANDAMENTO" class="tabcontent">
				<!---INICIO TABELA DE AVALIAÇÕES COM CADASTRO CONCLUÍDO, POREM, NÃO AVALIADAS--->
				
				<cfif rsInspecao.recordCount neq 0>
					<div id="form_container" name="divInsp" style="width:1100px;height:expression(this.scrollHeight>299?'300px':'auto');overflow-y:auto;">
						<table border="0" align="center"  id="tabInsp" style="width:expression(this.scrollHeight>299?'683px':'700px');">
							<tr>
								<td colspan="7" align="center" class="titulos"><h1 style="font-size:14px;background:#6699CC">AVALIAÇÕES COM CADASTRO FINALIZADO (Avaliações em Andamento)</h1></td>
							</tr>
							
							<tr bgcolor="#6699CC" class="exibir" align="center" style="color:#fff">
								<td width="5%">
									<div align="center">Número</div>
								</td>
								<td width="25%">
									<div align="center">Unidade</div>
								</td>
								<td width="7%">
									<div align="center">Percentual</div>
								</td>
								<td width="7%">
									<div align="center">Mod.</div>
								</td>

								<td width="15%">
									<div align="center">Período Previsto</div>
								</td>

								<td width="40%">
									<div align="center">Observações</div>
								</td>

								<td width="7%">
									<div align="center">Inspetores</div>
								</td>
								<td width="7%">
									<div align="center">Excluir</div>
								</td>

							</tr>
							
						
							<cfset scor = 'white'>
							<cfset avaliada = 0>
							<cfoutput query="rsInspecao">
							     
								    <cfquery datasource="#dsn_inspecao#" name="rsItensAvaliados" >
										Select count(RIP_Resposta) as avaliados FROM Resultado_Inspecao
										Where RIP_NumInspecao = '#rsInspecao.INP_NumInspecao#' and RIP_Resposta!='A' and (RIP_Recomendacao!='S' or RIP_Recomendacao is null)
									</cfquery>
									<!---<cfdump  var="#rsItensAvaliados#"> --->
									<cfquery datasource="#dsn_inspecao#" name="rsItensTotais" >
										Select count(RIP_Resposta) as total FROM Resultado_Inspecao
										Where RIP_NumInspecao = '#rsInspecao.INP_NumInspecao#'
									</cfquery>
									<cfquery datasource="#dsn_inspecao#" name="rsItemNCI" >
										Select RIP_NCISEI FROM Resultado_Inspecao
										Where RIP_NumInspecao = '#rsInspecao.INP_NumInspecao#' and Rtrim(Ltrim(RIP_NCISEI)) !=''
									</cfquery>
								
									<cfquery datasource="#dsn_inspecao#" name="rsEmReavaliacao" >
										Select RIP_Resposta, RIP_Recomendacao FROM Resultado_Inspecao
										Where RIP_NumInspecao = '#rsInspecao.INP_NumInspecao#' and RIP_Recomendacao ='S'
									</cfquery>
									
									<cfquery datasource="#dsn_inspecao#" name="rsReavaliado" >
										Select RIP_Resposta, RIP_Recomendacao FROM Resultado_Inspecao
										Where RIP_NumInspecao = '#rsInspecao.INP_NumInspecao#' and RIP_Recomendacao ='R' 
									</cfquery>

								
									<cfquery datasource="#dsn_inspecao#" name="rsInspetorTable2">
										SELECT Fun_Matric, Fun_Nome, Dir_Sigla FROM Funcionarios 
										INNER JOIN Diretoria ON  Dir_Codigo = Fun_DR
										WHERE Fun_Matric =#rsInspecao.INP_Coordenador#
									</cfquery>
									<cfset perInspec='#DateFormat(rsInspecao.INP_DtInicInspecao,"dd/mm/yyyy")#' & ' a ' & '#DateFormat(rsInspecao.INP_DtFimInspecao,"dd/mm/yyyy")#'>
								<form action="" method="POST">

										<tr id="#rsInspecao.CurrentRow#" valign="middle" bgcolor="#scor#" class="exibir"
											onMouseOver="mouseOver(this);" 
											onMouseOut="mouseOut(this);"
											onclick="gravaOrdLinha(this);"
											style="cursor:pointer">
													<td width="5%" onClick="capturaPosicaoScroll();window.open('itens_inspetores_avaliacao.cfm?numInspecao=#INP_NumInspecao#&Unid=#INP_Unidade#','_blank');">
														<div align="left">
															#INP_NumInspecao#
														</div>
													</td>


													<cfif '#rsItensAvaliados.avaliados#' gt 0>
														<cfset perc=round(('#rsItensAvaliados.avaliados#' / '#rsItensTotais.total#' )*100)>
														<cfif '#perc#' lt 1>
															<cfset perc='1%'>
														<cfelse>
															<cfset perc=round(('#rsItensAvaliados.avaliados#' / '#rsItensTotais.total#')*100) & '%'>
														</cfif>
														<cfif '#perc#' gte 99.5 and '#perc#' lt 100>
															<cfset perc="99%">
														</cfif>
													<cfelse>
															<cfset perc='0%'>
													</cfif>
													<td width="25%"  onclick="capturaPosicaoScroll();window.open('itens_inspetores_avaliacao.cfm?numInspecao=#INP_NumInspecao#&Unid=#INP_Unidade#','_blank');">
													    
														    	#trim(Dir_Sigla)#-#trim(Und_Descricao)#	
														<!---								
															<div align="left" style="background:red;width:'#perc#';height:5%;position:relative">
																<div align="center" style="color:white">#perc#</div>
															</div>
														--->
													</td>
													<td width="7%">
														<div align="left" style="background:red;width:'#perc#';height:5%;position:relative">
															<div align="center" style="color:white">#perc#</div>
														</div>
													</td>

													<td width="7%" onClick="capturaPosicaoScroll();window.open('itens_inspetores_avaliacao.cfm?numInspecao=#INP_NumInspecao#&Unid=#INP_Unidade#','_blank');">
														<div align="center">
															<cfif #INP_Modalidade# eq 0>PRES.<CFELSE>A DIST.</CFIF>
														</div>
													</td>
													<td width="15%" onClick="capturaPosicaoScroll();window.open('itens_inspetores_avaliacao.cfm?numInspecao=#INP_NumInspecao#&Unid=#INP_Unidade#','_blank');">
														<div align="center">#perInspec#</div>
													</td>
													<td width="40%" onClick="capturaPosicaoScroll();window.open('itens_inspetores_avaliacao.cfm?numInspecao=#INP_NumInspecao#&Unid=#INP_Unidade#','_blank');">
														<cfset temNCI="">
														<cfset NCI="">
														<cfif '#rsItemNCI.RecordCount#' gt 0>
															<cfif '#rsItemNCI.RecordCount#' eq 1>
															  <cfset temNCI="NCI: #rsItemNCI.RecordCount# item">
															<cfelse>
															  <cfset temNCI="NCI: #rsItemNCI.RecordCount# itens">
															</cfif>
														</cfif>
														<cfset emReanalise="">
														<cfif '#rsEmReavaliacao.RecordCount#' gt 0>
															<cfif '#rsEmReavaliacao.RecordCount#' eq 1>
														        <cfset emReanalise="Em Reanálise: #rsEmReavaliacao.RecordCount# item">
															<cfelse>
														    	<cfset emReanalise="Em Reanálise: #rsEmReavaliacao.RecordCount# itens">
															</cfif>	
														</cfif>
														<cfset reanalisado="">
														<cfif '#rsReavaliado.RecordCount#' gt 0>
															<cfif '#rsReavaliado.RecordCount#' eq 1>
														       <cfset reanalisado="Reanalisado: #rsReavaliado.RecordCount# item">
															<cfelse>
															   <cfset reanalisado="Reanalisado: #rsReavaliado.RecordCount# itens">
															</cfif>  
														</cfif>
														<div align="left" style="margin-left:10px">
															<div style="color:red;">#temNCI#</div>
															<div style="color:red;">#emReanalise#</div>
															<div style="color:darkBlue;">#reanalisado#</div>    
														</div>   
                                                        
													</td>
													
													<cfquery datasource="#dsn_inspecao#" name="rsInspCaInsp">
														SELECT * FROM Inspecao
														WHERE INP_NumInspecao = '#NIP_NumInspecao#'
													</cfquery>										
										<td width="7%" height="25px">	
													<div align="center">
											<a href="cadastro_inspecao_inspetores_alt.cfm?
											numInspecao=#rsInspCaInsp.INP_NumInspecao#
											&Unid=#rsInspCaInsp.INP_Unidade#
											&coordenador=#rsInspCaInsp.INP_Coordenador#
											&dtInicDeslocamento=#DateFormat(rsInspCaInsp.INP_DtInicDeslocamento,'dd/mm/yyyy')#
											&dtFimDeslocamento=#DateFormat(rsInspCaInsp.INP_DtFimDeslocamento,'dd/mm/yyyy')#
											&dtInicInspecao=#DateFormat(rsInspCaInsp.INP_DtInicInspecao,'dd/mm/yyyy')#
											&dtFimInspecao=#DateFormat(rsInspCaInsp.INP_DtFimInspecao,'dd/mm/yyyy')#
											&RIPMatricAvaliador=N
											&telaretorno=cadastro_inspecao.cfm
											##formCad"><img src="figuras/usuario.png" alt="Clique para cadastrar/visualizar inspetores" width="20" height="20" border="0" ></a>													
											</div>
										</td>														
													<td width="7%" height="25px">

														<cfif '#rsItensAvaliados.avaliados#' eq 0>
															<div align="center"><a
																	onclick="return confExc('NaoAvaliadas','Confirma a exclusão desta Avaliação? \n#trim(rsInspecao.INP_NumInspecao)#-#trim(Und_Descricao)#(#trim(Und_Codigo)#)')"
																	href="cadastro_inspecao.cfm?acao=excInsp&numInspecao=#rsInspecao.INP_NumInspecao#&unidade=#Und_Codigo#"><img
																		src="icones/lixeiraRosa.png" alt="Clique para excluir esta Avaliação"
																		width="17" height="17" border="0"></img></a></div>
														<cfelse>
															<cfset avaliada=1>
															<div align="center"><a
																			onclick="return confExc('NaoAvaliadas','Foram avaliados #rsItensAvaliados.avaliados# itens desta Avaliação.\n\nConfirma a exclusão definitiva desta Avaliação? \n\n#trim(rsInspecao.INP_NumInspecao)#-#trim(Und_Descricao)# (#trim(Und_Codigo)#)')"
																			href="cadastro_inspecao.cfm?acao=excInsp&numInspecao=#rsInspecao.INP_NumInspecao#&unidade=#Und_Codigo#"><img
																				src="icones/lixeiraRosa.png"
																				alt="Clique para excluir esta Avaliação" width="17" height="17"
																				border="0"></img></a></div>

														</cfif>
													</td>
										</tr>

								</form>

								<cfif scor eq 'white'>
									<cfset scor = 'f7f7f7'>
								<cfelse>
									<cfset scor = 'white'>
								</cfif>
							</cfoutput>


						</table>
					</div>
				<cfelse>
					<label>NÃO EXISTEM AVALIAÇÕES EM ANDAMENTO </label>
				</cfif>
				
		</div>

		<div id="EmRevisao" class="tabcontent" >
				<!---INICIO TABELA DE AVALIAÇÕES EM REVISÃO--->
				<cfif rsEmRevisaoFinalizadasSemNC.recordCount neq 0>
					
					<div id="form_container" name="divEmVerificacao" style="width:1500px;height:expression(this.scrollHeight>299?'300px':'auto');overflow-y:auto;">
					<table border="0" align="center"  id="tabEmVerificacao" style="width:expression(this.scrollHeight>299?'690px':'700px');">
						<tr>
							<td colspan="9" align="center" class="titulos"><h1 style="font-size:14px;background:#6699CC">AVALIAÇÕES FINALIZADAS (Em Revisão)</h1></td>
						</tr>
						
						<tr bgcolor="#6699CC" class="exibir" align="center" style="color:#fff">
							<td width="5%">
								<div align="center">Número</div>
							</td>
							<td width="25%">
								<div align="center">Unidade</div>
							</td>
							<td width="3%">
								<div align="center">Mod.</div>
							</td>
							<td width="8%">
								<div align="center">Transmissão Avaliação</div>
							</td>
							<td width="8%">
								<div align="center">Data Atualiz.</div>
							</td>
							<td width="15%">
								<div align="center">Observações</div>
							</td>
							<td width="20%">
								<div align="center">Última Transação</div>
							</td>
							<td width="25%">
								<div align="center">Revisor</div>
							</td>							
							<td width="5%">
								<div align="center">Inspetores</div>
							</td>
						</tr>

					<cfset scor = 'white'>
					<cfset avaliada = 0>
					<cfoutput query="rsEmRevisaoFinalizadasSemNC">
						<form action="" method="POST" >
							<cfquery datasource="#dsn_inspecao#" name="rsItemNCI">
								Select Pos_NCISEI FROM ParecerUnidade
								Where Pos_Inspecao = '#rsEmRevisaoFinalizadasSemNC.INP_NumInspecao#' and Rtrim(Ltrim(Pos_NCISEI)) !=''
							</cfquery>

							<cfquery datasource="#dsn_inspecao#" name="rsEmReavaliacao" >
								Select RIP_Resposta, RIP_Recomendacao FROM Resultado_Inspecao
								Where RIP_NumInspecao = '#rsEmRevisaoFinalizadasSemNC.INP_NumInspecao#' and RIP_Recomendacao ='S'
							</cfquery>
							<cfquery datasource="#dsn_inspecao#" name="rsReavaliado" >
								Select RIP_Resposta, RIP_Recomendacao FROM Resultado_Inspecao
								Where RIP_NumInspecao = '#rsEmRevisaoFinalizadasSemNC.INP_NumInspecao#' and RIP_Recomendacao ='R'
							</cfquery>
							
							<cfquery datasource="#dsn_inspecao#" name="rsInspetorTable2">
								SELECT Fun_Matric, Fun_Nome, Dir_Sigla FROM Funcionarios 
								INNER JOIN Diretoria ON  Dir_Codigo = Fun_DR 
								WHERE Fun_Matric =#rsEmRevisaoFinalizadasSemNC.INP_Coordenador#
							</cfquery>



						<cfset fimaval = '#DateFormat(rsEmRevisaoFinalizadasSemNC.INP_DTConcluirAvaliacao,'dd/mm/yyyy')#' >
						<cfset perInspec = '#DateFormat(rsEmRevisaoFinalizadasSemNC.INP_DtUltAtu,'dd/mm/yyyy')# #timeFormat(rsEmRevisaoFinalizadasSemNC.INP_DtUltAtu, "HH:MM")#'>

						<cfset semNCvalidado = false>
						<cfquery datasource="#dsn_inspecao#" name="rsSemValidacao" >
							SELECT  Count(RIP_NumInspecao) as total
									, Count(CASE WHEN RIP_Recomendacao='V' THEN 1 END) AS validado 
							FROM Resultado_Inspecao
							WHERE RIP_NumInspecao = '#INP_NumInspecao#' 
						</cfquery>
						<!---FIM - Verifica se é uma verifcação sem itens não conforme--->
						<cfif "#rsSemValidacao.total#" eq "#rsSemValidacao.validado#"  and "#rsSemValidacao.total#" neq 0>
							<cfset semNCvalidado = true>
						</cfif>		    	
					   
							<tr id="#rsEmRevisaoFinalizadasSemNC.CurrentRow#" valign="middle" bgcolor="#scor#"  class="exibir" 
								onMouseOver="mouseOver(this);" 
                                onMouseOut="mouseOut(this);"
                                onclick="gravaOrdLinha(this);"
								style="cursor:pointer">
											
									<cfset temNCI = "">
									<cfif '#rsItemNCI.RecordCount#' gt 0>
									<cfset temNCI = "NCI:#rsItemNCI.RecordCount#">
									</cfif>

									<cfset emReavaliacao="">
									<cfif '#rsEmReavaliacao.RecordCount#' gt 0>
									<cfset emReavaliacao="EmRean:#rsEmReavaliacao.RecordCount#">
									</cfif>
									<cfset reanalisado="">
									<cfif '#rsReavaliado.RecordCount#' gt 0>
									<cfset reanalisado="Rean:#rsReavaliado.RecordCount#">
									</cfif>


									<td width="5%">
										<div align="left" onClick="capturaPosicaoScroll();window.open('GeraRelatorio/gerador/dsp/papeltrabalho.cfm?pg=controle&Form.id=#INP_NumInspecao#','_blank');">
											#rsEmRevisaoFinalizadasSemNC.INP_NumInspecao#
										</div>
									</td>

									
									<td width="25%" onClick="capturaPosicaoScroll();window.open('GeraRelatorio/gerador/dsp/papeltrabalho.cfm?pg=controle&Form.id=#INP_NumInspecao#','_blank');">
										<div align="left" >#trim(Dir_Sigla)#-#trim(Und_Descricao)#								
										</div>
									</td>
									
									<td width="3%" onClick="capturaPosicaoScroll();window.open('GeraRelatorio/gerador/dsp/papeltrabalho.cfm?pg=controle&Form.id=#INP_NumInspecao#','_blank');">
											<div align="center"><cfif #INP_Modalidade# eq 0>PRES.<CFELSE>A DIST.</CFIF></div>
									</td>
									
									<td width="8%" onClick="capturaPosicaoScroll();window.open('GeraRelatorio/gerador/dsp/papeltrabalho.cfm?pg=controle&Form.id=#INP_NumInspecao#','_blank');">
										<div align="center">#fimaval#</div>
									</td>
									<td width="8%" onClick="capturaPosicaoScroll();window.open('GeraRelatorio/gerador/dsp/papeltrabalho.cfm?pg=controle&Form.id=#INP_NumInspecao#','_blank');">
										<div align="center">#perInspec#</div>
									</td>
									<td width="15%" onClick="capturaPosicaoScroll();window.open('GeraRelatorio/gerador/dsp/papeltrabalho.cfm?pg=controle&Form.id=#INP_NumInspecao#','_blank');">
										<cfset temNCI="">
										<cfset NCI="">
										<cfif '#rsItemNCI.RecordCount#' gt 0>
											<cfif '#rsItemNCI.RecordCount#' eq 1>
											<cfset temNCI="NCI: #rsItemNCI.RecordCount# item">
											<cfelse>
											<cfset temNCI="NCI: #rsItemNCI.RecordCount# itens">  
											</cfif>
										</cfif>
										<cfset emReanalise="">
										<cfif '#rsEmReavaliacao.RecordCount#' gt 0>
											<cfif '#rsEmReavaliacao.RecordCount#' eq 1>
												<cfset emReanalise="Em Reanálise: #rsEmReavaliacao.RecordCount# item">
											<cfelse>
												<cfset emReanalise="Em Reanálise: #rsEmReavaliacao.RecordCount# itens">
											</cfif>
										</cfif>
										<cfset reanalisado="">
										<cfif '#rsReavaliado.RecordCount#' gt 0>
											<cfif '#rsReavaliado.RecordCount#' eq 1>
											<cfset reanalisado="Reanalisado: #rsReavaliado.RecordCount# item">
											<cfelse>
											<cfset reanalisado="Reanalisado: #rsReavaliado.RecordCount# itens">
											</cfif>
										</cfif>
										<cfset semNC="">
										<cfif '#rsEmRevisaoFinalizadasSemNC.tipo#' eq 'semNC'>
											<cfset semNC='Sem Itens "NÃO CONFORME"' >
										</cfif>

										<div align="left" style="margin-left:10px">
											<div style="color:red;">#temNCI#</div>
											<div style="color:red;">#emReanalise#</div>
											<div style="color:darkBlue;">#reanalisado#</div>
											<div style="color:red;">#semNC#</div>    
										</div>  						 
																
									</td>
									<cfquery datasource="#dsn_inspecao#" name="rsInspCaInsp">
										SELECT * from Inspecao INNER JOIN Usuarios ON INP_UserName = Usu_Login 
										WHERE INP_NumInspecao = '#INP_NumInspecao#'
									</cfquery>
									<cfset revisor = 'SEM REVISOR(A)'>
									<cfif trim(rsInspCaInsp.INP_RevisorLogin) gt 0>
										<cfquery name="rsRevis" datasource="#dsn_inspecao#">
											select Usu_Apelido 
											from usuarios 
											where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#rsInspCaInsp.INP_RevisorLogin#">)
										</cfquery>
										<cfset revisor = rsRevis.Usu_Apelido>
									</cfif>
								<!---									
									<cfset UsuApelido = ''>
									<cfif ucase(trim(rsInspCaInsp.Usu_GrupoAcesso)) eq 'GESTORES'> --->
										<cfset UsuApelido = rsInspCaInsp.Usu_Apelido>
								<!---								</cfif> --->
									<td width="20%" onClick="capturaPosicaoScroll();window.open('GeraRelatorio/gerador/dsp/papeltrabalho.cfm?pg=controle&Form.id=#INP_NumInspecao#','_blank');">
										<div align="left">#UsuApelido#</div>
									</td>

									<td width="25%" onClick="capturaPosicaoScroll();if('#revisor#' != 'SEM REVISOR(A)'){window.open('GeraRelatorio/gerador/dsp/papeltrabalho.cfm?pg=controle&Form.id=#INP_NumInspecao#','_blank')} else {if (confirm ('                       Atenção! \n\nConfirma Assumir a Revisão?')) {window.open('cadastro_inspecao.cfm?numInspecao=#rsInspCaInsp.INP_NumInspecao#&Unid=#rsInspCaInsp.INP_Unidade#&acao=assumirevisao','_self')}}">
										<div align="left">
											<cfif revisor eq 'SEM REVISOR(A)'>
												<button name="assumirrevisao" type="button" class="botao">Assumir Revisão?</button>
												 <!--- <a href="##">Assumir Revisão?</a>	--->												
											<cfelse>
												<div align="left">#revisor#</div>
											</cfif>
										</div>	
									</td>
									<td width="5%" height="25px">
										<!--- <div align="center"><a  onclick="abrirFormInspetores('#rsInspCaInsp.INP_NumInspecao#',#rsInspCaInsp.INP_Coordenador#)" href="##0"><img src="figuras/usuario.png" alt="Clique para visualizar os inspetores desta Avaliação" width="20" height="20" border="0" ></img></a></div> --->
										<div align="center">
											<a href="cadastro_inspecao_inspetores_alt.cfm?
											numInspecao=#rsInspCaInsp.INP_NumInspecao#
											&Unid=#rsInspCaInsp.INP_Unidade#
											&coordenador=#rsInspCaInsp.INP_Coordenador#
											&dtInicDeslocamento=#DateFormat(rsInspCaInsp.INP_DtInicDeslocamento,'dd/mm/yyyy')#
											&dtFimDeslocamento=#DateFormat(rsInspCaInsp.INP_DtFimDeslocamento,'dd/mm/yyyy')#
											&dtInicInspecao=#DateFormat(rsInspCaInsp.INP_DtInicInspecao,'dd/mm/yyyy')#
											&dtFimInspecao=#DateFormat(rsInspCaInsp.INP_DtFimInspecao,'dd/mm/yyyy')#
											&RIPMatricAvaliador=N
											&telaretorno=cadastro_inspecao.cfm
											##formCad"><img src="figuras/usuario.png" alt="Clique para cadastrar/visualizar inspetores" width="20" height="20" border="0" ></a>													
										</div>										
									</td>
							</tr>
						
					</form>

					<cfif scor eq 'white'>
						<cfset scor = 'f7f7f7'>
					<cfelse>
						<cfset scor = 'white'>
					</cfif>
					</cfoutput>


					</table>
					
					</div>
					<cfelse>
					<label>NÃO EXISTEM AVALIAÇÕES FINALIZADAS (EM REVISÃO)</label>
					</cfif>
		</div>
		<div id="VlrAloc" class="tabcontent" >
				<!---INICIO TABELA DE valores alocados --->
				<cfif rsvlralocado.recordCount neq 0>
					
					<div id="form_container" name="divEmVerificacao" style="width:1300px;height:expression(this.scrollHeight>299?'300px':'auto');overflow-y:auto;">
					<table border="0" align="center"  id="tabEmVerificacao" style="width:expression(this.scrollHeight>299?'690px':'700px');">
						<tr>
							<td colspan="9" align="center" class="titulos"><h1 style="font-size:14px;background:#6699CC">Fazer Registro dos Valores Alocados</h1></td>
						</tr>
						
						<tr bgcolor="#6699CC" class="exibir" align="center" style="color:#fff">
							<td width="5%">
								<div align="center">Número</div>
							</td>
							<td width="25%">
								<div align="center">Unidade</div>
							</td>
							<td width="3%">
								<div align="center">Mod.</div>
							</td>
							<td width="8%">
								<div align="center">Conclusão Avaliação</div>
							</td>
							<td width="25%">
								<div align="center">Revisor</div>
							</td>							
						</tr>

					<cfset scor = 'white'>
					<cfset avaliada = 0>
					<cfoutput query="rsvlralocado">
						<form action="" method="POST" >

						<cfset fimaval = '#DateFormat(rsvlralocado.INP_DTConcluirAvaliacao,'dd/mm/yyyy')#' >  	
					   
							<tr id="#rsvlralocado.CurrentRow#" valign="middle" bgcolor="#scor#"  class="exibir" 
								onMouseOver="mouseOver(this);" 
                                onMouseOut="mouseOut(this);"
                                onclick="gravaOrdLinha(this);"
								style="cursor:pointer">							
									<td width="5%">
										<div align="left" onClick="capturaPosicaoScroll();window.open('cadastro_inspecao_despesas.cfm?numInspecao=#rsvlralocado.INP_NumInspecao#','_blank');">
											#rsvlralocado.INP_NumInspecao#
										</div>
									</td>
									<td width="25%" onClick="capturaPosicaoScroll();window.open('cadastro_inspecao_despesas.cfm?numInspecao=#rsvlralocado.INP_NumInspecao#','_blank');">
										<div align="left" >#trim(Dir_Sigla)#-#rsvlralocado.Und_Descricao#								
										</div>
									</td>
									
									<td width="3%" onClick="capturaPosicaoScroll();window.open('cadastro_inspecao_despesas.cfm?numInspecao=#rsvlralocado.INP_NumInspecao#','_blank');">
											<div align="center"><cfif #rsvlralocado.INP_Modalidade# eq 0>PRES.<CFELSE>A DIST.</CFIF></div>
									</td>
									
									<td width="8%" onClick="capturaPosicaoScroll();window.open('cadastro_inspecao_despesas.cfm?numInspecao=#rsvlralocado.INP_NumInspecao#','_blank');">
										<div align="center">#fimaval#</div>
									</td>
									<cfset revisor = 'SEM REVISOR(A)'>
									<cfif trim(rsvlralocado.Usu_Apelido) neq ''>
										<cfset revisor = trim(rsvlralocado.Usu_Apelido)>
									</cfif>

									<td width="25%" onClick="capturaPosicaoScroll();if('#revisor#' != 'SEM REVISOR(A)'){window.open('cadastro_inspecao_despesas.cfm?numInspecao=#INP_NumInspecao#','_blank')} else {if (confirm ('                       Atenção! \n\nConfirma Assumir a Revisão?')) {window.open('cadastro_inspecao.cfm?numInspecao=#rsInspCaInsp.INP_NumInspecao#&Unid=#rsInspCaInsp.INP_Unidade#&acao=assumirevisao','_self')}}">
										<div align="left">
												<div align="left">#revisor#</div>
										</div>	
									</td>
							</tr>
						
					</form>

					<cfif scor eq 'white'>
						<cfset scor = 'f7f7f7'>
					<cfelse>
						<cfset scor = 'white'>
					</cfif>
					</cfoutput>


					</table>
					
					</div>
					<cfelse>
					<label>NÃO EXISTEM AVALIAÇÕES FINALIZADAS (EM REVISÃO)</label>
					</cfif>
		</div>
		<div id="SemNC" class="tabcontent" >
			<!---INICIO TABELA DE AVALIAÇÕES SEM ITENS NC--->
			<cfif rsFinalizadasSemNCencerrado.recordCount neq 0>
				<div id="form_container" name="divSemNC" style="width:680px;height:expression(this.scrollHeight>299?'300px':'auto');overflow-y:auto;">
					<table border="0" align="center" id="tabSemNC" style="width:expression(this.scrollHeight>299?'683px':'700px');">
						<tr style="border:none;">
							<td colspan="7" align="center">
								<h1 style="font-size:14px;background:#6699CC;color:white;border:none">
									AVALIAÇÕES FINALIZADAS SEM OPORTUNIDADES DE APRIMORAMENTO</h1>
							</td>
						</tr>

						<tr bgcolor="#6699CC" class="exibir" align="center" style="color:white">
							<td width="7%">
								<div align="center">Número</div>
							</td>
							<td width="40%">
								<div align="center">Unidade</div>
							</td>
							<td width="7%">
								<div align="center"></div>Mod.

							</td>
							<td width="40%">
								<div align="center">Coordenador</div>
							</td>

							<td width="5%">
								<div align="center">Data Finalização</div>
							</td>
							
							<td width="5%">
								<div align="center">Inspetores</div>
							</td>
						</tr>

								<cfset scor='white'>
								<cfset avaliada=0>
								<cfoutput query="rsFinalizadasSemNCencerrado">
									<form action="" method="POST">
										
										
										<cfquery datasource="#dsn_inspecao#" name="rsInspetorTable2">
											SELECT Fun_Matric, Fun_Nome, Dir_Sigla FROM Funcionarios 
										    INNER JOIN Diretoria ON  Dir_Codigo = Fun_DR 
											WHERE Fun_Matric=#rsFinalizadasSemNCencerrado.INP_Coordenador#
										</cfquery>
										<cfset perInspec='#DateFormat(rsFinalizadasSemNCencerrado.INP_DtEncerramento,'dd/mm/yyyy')#'> 

 										

										<tr	id="#rsFinalizadasSemNCencerrado.CurrentRow#" valign="middle" bgcolor="#scor#" class="exibir"
											onMouseOver="mouseOver(this);" 
                                    		onMouseOut="mouseOut(this);"
                                    		onclick="gravaOrdLinha(this);"
											style="cursor:pointer"
											>
											<td width="7%"
											onclick="capturaPosicaoScroll();window.open('GeraRelatorio/gerador/dsp/papeltrabalho.cfm?pg=controle&Form.id=#INP_NumInspecao#','_blank')">
											<div align="left">
												#rsFinalizadasSemNCencerrado.INP_NumInspecao#
												
											</td>


											<td width="40%"
											onclick="capturaPosicaoScroll();window.open('GeraRelatorio/gerador/dsp/papeltrabalho.cfm?pg=controle&Form.id=#INP_NumInspecao#','_blank')">
												<div align="left">#trim(Dir_Sigla)#-#trim(Und_Descricao)#
													
											</td>

											<td width="7%"
											onclick="capturaPosicaoScroll();window.open('GeraRelatorio/gerador/dsp/papeltrabalho.cfm?pg=controle&Form.id=#INP_NumInspecao#','_blank')">
												<div align="center">
													<cfif #INP_Modalidade# eq 0>PRES.<CFELSE>A DIST.</CFIF>
												</div>
											</td>
											<td width="40%"
											onclick="capturaPosicaoScroll();window.open('GeraRelatorio/gerador/dsp/papeltrabalho.cfm?pg=controle&Form.id=#INP_NumInspecao#','_blank')">
												<div align="left">#trim(rsInspetorTable2.Fun_Nome)#
													(#trim(rsInspetorTable2.Fun_Matric)#-#trim(rsInspetorTable2.Dir_Sigla)#)</div>
											</td>
											<td width="5%"
											onclick="capturaPosicaoScroll();window.open('GeraRelatorio/gerador/dsp/papeltrabalho.cfm?pg=controle&Form.id=#INP_NumInspecao#','_blank')">
												<div align="left">#perInspec#</div>
											</td>

											
											<cfquery datasource="#dsn_inspecao#" name="rsInspCaInsp">
												SELECT * FROM Inspecao
												WHERE INP_NumInspecao = '#INP_NumInspecao#'

											</cfquery>
											<td width="5%" height="25px" style="z-index:10000">
												<div align="center" style="z-index:10000"><a
														onclick="abrirFormInspetores('#rsInspCaInsp.INP_NumInspecao#',#rsInspCaInsp.INP_Coordenador#)"
														href="##0"><img src="figuras/usuario.png"
															alt="Clique para visualizar os inspetores desta Avaliação" width="20"
															height="20" border="0" style="z-index:10000"></img></a></div>
											</td>
										</tr>

									</form>

									<cfif scor eq 'white'>
										<cfset scor='f7f7f7'>
									<cfelse>
										<cfset scor='white'>
									</cfif>
								</cfoutput>
					</table>
				</div>
			<cfelse>
			<label>NÃO EXISTEM AVALIAÇÕES SEM ITENS NÃO-CONFORMES</label>
			</cfif>
			<!---FIM TABELA DE AVALIAÇÕES SEM ITENS NC--->
		</div>

		<div id="Excluidas" class="tabcontent" >
			<!---INICIO TABELA DE AVALIAÇÕES EXCLUÍDAS--->
			<cfif rsExcluidas.recordCount neq 0>
				<div id="form_container" name="diExcluidas" style="width:680px;height:expression(this.scrollHeight>299?'300px':'auto');overflow-y:auto;">
					<table border="0" align="center" id="tabExcluidas" style="width:expression(this.scrollHeight>299?'683px':'700px');">
						<tr style="border:none;">
							<td colspan="7" align="center">
								<h1 style="font-size:14px;background:#6699CC;color:white;border:none">
									AVALIAÇÕES EXCLUÍDAS</h1>
							</td>
						</tr>

						<tr bgcolor="#6699CC" class="exibir" align="center" style="color:white">
							<td width="7%">
								<div align="center">Número</div>
							</td>
							<td width="40%">
								<div align="center">Unidade</div>
							</td>
							<td width="5%">
								<div align="center">Data Prevista</div>
							</td>
							<td width="35%">
								<div align="center">Excluído por</div>
							</td>
							<td width="5%">
								<div align="center">Data Exclusão</div>
							</td>
							
						</tr>

								<cfset scor='white'>
								<cfset avaliada=0>
								<cfoutput query="rsExcluidas">
									<cfquery datasource="#dsn_inspecao#" name="rsEmpregExc">
										SELECT Usu_Matricula, Usu_Apelido, Dir_Sigla FROM Usuarios 
										INNER JOIN Diretoria ON  Dir_Codigo = Usu_DR 
										WHERE Usu_Matricula =convert(varchar,#NIP_UserName#)
									</cfquery>

									<form action="" method="POST">
										
										<cfset perInspec='#DateFormat(rsExcluidas.NIP_DtIniPrev,'dd/mm/yyyy')#'> 
										<cfset dtExc='#DateFormat(rsExcluidas.NIP_DtUltAtu,'dd/mm/yyyy')#'> 
										<tr id="#rsExcluidas.CurrentRow#" valign="middle" bgcolor="#scor#" class="exibir"
										    onMouseOver="mouseOver(this);" 
                                    		onMouseOut="mouseOut(this);"
                                    		>
											
											<td width="7%">
												<div align="left">#rsExcluidas.NIP_NumInspecao#</div>
											</td>


											<td width="40%">
												<div align="left">#trim(Dir_Sigla)#-#trim(Und_Descricao)#
													
											</td>
											
											<td width="5%">
												<div align="left">#perInspec#</div>
											</td>

											<td width="35%">
												<div align="left">#trim(rsEmpregExc.Usu_Apelido)#
													(#trim(rsEmpregExc.Usu_Matricula)#-#trim(rsEmpregExc.Dir_Sigla)#)</div>
											</td>
											<td width="5%">
												<div align="center">#dtExc#</div>
											</td>
											
											
											</tr>

									</form>

									<cfif scor eq 'white'>
										<cfset scor='f7f7f7'>
									<cfelse>
										<cfset scor='white'>
									</cfif>
								</cfoutput>
					</table>
				</div>
			<cfelse>
			<label>NÃO EXISTEM AVALIAÇÕES EXCLUÝDAS</label>
			</cfif>
			<!---FIM TABELA DE AVALIAÇÕES EXCLUÝDAS--->
		</div>
</div>


	<script type="text/javascript">
	    //funções que controlam as tabs

		function confExc(div,mens){
			aguarde('titulo');
			if(window.confirm(mens)){
				capturaPosicaoScroll();
				return true;  
			}else{
				aguarde('titulo');
				return false;  	
			}
		}
		function getElementsByClassName(node, classname) {
			var a = [];
			var re = new RegExp('(^| )'+classname+'( |$)');
			var els = node.getElementsByTagName("*");
			for(var i=0,j=els.length; i<j; i++)
				if(re.test(els[i].className))a.push(els[i]);
			return a;
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
		function openPage(pageName,elmnt,color) {
			sessionStorage.removeItem('idLinha');
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

		<cfoutput>
			var nf = '#rsNumeraInspecao.recordCount#';
			var final = '#rsInspecao.recordCount#';
			var emRev = '#rsEmRevisaoFinalizadasSemNC.recordCount#';
		</cfoutput>

		// Buscar se tem uma aba atual selecionada
        var aba = sessionStorage.getItem('abaAtual');

		if(aba !=null){
			document.getElementById(aba).click(); 
		}else{		
			if(nf != 0){
				document.getElementById('naoFinaliz').click();  
			}else if(final != 0){
				document.getElementById('naoAval').click();
			}else if(emRev !=0){
				document.getElementById('emRev').click();
			}else{ 
				document.getElementById('naoFinaliz').click();
			}
		}

		// var ancora = window.location.href.split("#")[1];
		// if(ancora == "naoAvaliado" || ancora == "naoAval") {
		//     document.getElementById('naoAval').click();
		// }
		
		//inicio controle cor das abas em hover e out
		var txt = navigator.appName;
		
		function corHover(aba){
			
			if (txt == 'Microsoft Internet Explorer'){	
				// alert(aba.style.backgroundColor)
				if(aba.style.backgroundColor!='#6699cc'){
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
	</script>


</cfif>



<!---INICIO DA TABELA DE INSPETORES CADASTRADOS--->
<cfif '#url.acao#' eq "inspCad">
	<cfquery datasource="#dsn_inspecao#" name="rsInspetoresCadastrados">
		SELECT Inspetor_Inspecao.*, Funcionarios.*, Diretoria.*, Und_Descricao FROM Inspetor_Inspecao 
		INNER JOIN Unidades on IPT_CodUnidade = Und_Codigo
		INNER JOIN Funcionarios on IPT_MatricInspetor = Fun_Matric
		INNER JOIN Diretoria ON  Dir_Codigo = Fun_DR
		WHERE IPT_NumInspecao = '#url.numInspecao#'
		ORDER BY Fun_Nome
		
	</cfquery>

	<cfif rsInspetoresCadastrados.recordCount neq 0>
		<div id="form_container" style ="position:relative;top:-40px;width:650px;">
			<table width="650px" border="0" align="center" >
				<tr bgcolor="write">
					<td colspan="8" align="center" class="titulos">
						<h1 style="font-size:14px;background-color:#818819">INSPETORES - Aval.: <CFOUTPUT>#rsInspetoresCadastrados.IPT_NumInspecao# - #rsInspetoresCadastrados.Und_Descricao#</CFOUTPUT></h1>
					</td>
				</tr>

				<tr bgcolor="#818819" class="exibir" align="center" style="color:#fff">
					<td width="10%">
						<div align="center">MATRÍCULA</div>
					</td>
					<td width="30%">
						<div align="center">NOME</div>
					</td>
					<td width="5%">
						<div align="center">H. PRÉ-AVAL.</div>
					</td>

					<td width="5%">
						<div align="center">DESLOC.</div>
					</td>

					<td width="5%">
						<div align="center">H. DESC.</div>
					</td>
					<td width="5%">
						<div align="center">AVALIAÇÃO</div>
					</td>

					<td width="5%">
						<div align="center">H. AVAL.</div>
					</td>


				</tr>
				<tr>

					<cfset scor='white'>
						<cfoutput query="rsInspetoresCadastrados">
							<form action="" method="POST" name="formexc">
								<cfif '#rsInspetoresCadastrados.IPT_DtInicDesloc#' neq '1900/1/1'>
									<cfset perDesloc='#DateFormat(IPT_DtInicDesloc,'dd/mm/yyyy')#' & ' a ' & '#DateFormat(IPT_DtFimDesloc,'dd/mm/yyyy')#'> 
								<cfelse>
								    <cfset perDesloc="não houve">
								</cfif>
								<cfset perInspec='#DateFormat(IPT_DtInicInsp,'dd/mm/yyyy')#' & ' a '
									& '#DateFormat(IPT_DtFimInsp,'dd/mm/yyyy')#'>
								<cfset maskmatrusu = left(IPT_MatricInspetor,1) & '.' & mid(IPT_MatricInspetor,2,3) & '.***-' & right(IPT_MatricInspetor,1)>										
								<tr valign="middle" bgcolor="#scor#" class="exibir"
									onMouseOver="mouseOver(this);" 
                                    onMouseOut="mouseOut(this);"
                                    onclick="gravaOrdLinha(this);">
									<td width="7%">
										<div align="center">#maskmatrusu#</div>
									</td>
									
										<td width="20%">
											<cfif '#IPT_MatricInspetor#' eq '#url.coordenador#'>
											   <div align="left"><strong>#trim(Fun_Nome)# (#trim(Dir_Sigla)#) (coordenador)</strong></div>
										    <cfelse>
												<div align="left">#trim(Fun_Nome)# (#trim(Dir_Sigla)#)</div>
										    </cfif>
										</td>
									

									<td width="5%">
										<div align="center">#IPT_NumHrsPreInsp#h</div>
									</td>

									<td width="10%">
										<div align="left">#perDesloc#</div>
									</td>

									<td width="5%">
										<div align="center">#IPT_NumHrsDesloc#h</div>
									</td>
									<td width="10%">
										<div align="left">#perInspec#</div>
									</td>

									<td width="5%">
										<div align="center">#IPT_NumHrsInsp#h</div>
									</td>

									</tr>

							</form>

				<cfif scor eq 'white'>
					<cfset scor='f7f7f7'>
						<cfelse>
							<cfset scor='white'>
				</cfif>
				</cfoutput>
			</table>
			
		</div>	

	</cfif>
</cfif>
</body>
<script src="public/jquery-3.7.1.min.js"></script>
<script type="text/javascript">
	$('#cbvlrprev').click(function(){  
		let title = $(this).attr('title')
		if(title == 'inativo'){
			$('#cbvlrprev').attr('title','ativo')
			$('#inpvalorprevisto').val('0,00')
			$("#inpvalorprevisto").prop('readonly', true);	
		}else{
			$('#cbvlrprev').attr('title','inativo')
			$('#inpvalorprevisto').val('0,00')
			$("#inpvalorprevisto").prop('readonly', false)
		}
		//alert($("#cbvlrprev").prop("checked"))
	})	
</script>
</html>