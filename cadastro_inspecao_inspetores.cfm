<cfprocessingdirective pageEncoding ="utf-8"/>
 <cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	<cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
  </cfif> 
  
  <cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_DR,Usu_GrupoAcesso, Usu_Matricula, Usu_Email, Usu_Apelido,Usu_Coordena,Usu_login from usuarios 
	where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

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

<cfquery datasource="#dsn_inspecao#" name="rsInspecoes">
	SELECT * FROM Inspecao 
	INNER JOIN Numera_Inspecao ON INP_NumInspecao = NIP_NumInspecao
	WHERE  left(INP_NumInspecao,2) in(#se#) and INP_Situacao ='NA' and NIP_Situacao = 'P'
	ORDER BY INP_Coordenador;
</cfquery>

<cfset nInsp = ''>
<cfset color =''>

<!--- Rotina para exclusão de inspetores --->
<cfif isdefined('url.acao')>			
	<cfif '#url.acao#' eq 'excInspetor'>
		<cfquery datasource="#dsn_inspecao#">
			DELETE FROM Inspetor_Inspecao WHERE IPT_NumInspecao=rtrim(ltrim(convert(varchar,'#url.numInspecao#'))) and
			IPT_MatricInspetor=rtrim(ltrim('#url.numMatricula#'))
		</cfquery>
		<cflocation url = "cadastro_inspecao_inspetores.cfm?numInspecao=#url.NumInspecao#&coordenador=#url.coordenador#&dtInicDeslocamento=#url.dtInicDeslocamento#&dtFimDeslocamento=#url.dtFimDeslocamento#&dtInicInspecao=#url.dtInicInspecao#&dtFimInspecao=#url.dtFimInspecao###tabInsp" addToken = "no">
	</cfif>
</cfif>

<cfif isDefined("url.numInspecao")>

	<cfset nInsp = '#url.numInspecao#'>
	<cfset color ='yellow'>
	<cfquery datasource="#dsn_inspecao#" name="rsInspecao">
		SELECT * FROM Inspecao WHERE INP_NumInspecao = '#url.numInspecao#' and INP_Situacao='NA'
	</cfquery>

	<cfquery datasource="#dsn_inspecao#" name="rsUnidade">
		SELECT *  FROM Unidades WHERE Und_Status='A' and Und_Codigo = '#rsInspecao.INP_Unidade#'
	</cfquery>
    
	<cfset inspecao = "#rsInspecao.INP_NumInspecao# - #rsUnidade.Und_Descricao# (#rsUnidade.Und_Codigo#)">
	<cfset modalidade = #rsInspecao.INP_Modalidade#>

	 <cfif isDefined("form.selInspetores") and '#form.selInspetores#' neq "" >
		<cftransaction> 
			<cfloop list="#form.selInspetores#" index="i">  
				<cfquery datasource="#dsn_inspecao#" name="rsNumera_Inspecao_verif">
					Select IPT_NumInspecao FROM Inspetor_inspecao  WHERE IPT_NumInspecao = convert(varchar,'#rsInspecao.INP_NumInspecao#') and IPT_MatricInspetor = '#i#'
				</cfquery>
	
				<cfquery datasource="#dsn_inspecao#">
					insert into Inspetor_Inspecao (IPT_CodUnidade, IPT_NumInspecao, IPT_MatricInspetor, IPT_DtInicInsp, IPT_DtFimInsp, IPT_DtInicDesloc, IPT_DtFimDesloc, IPT_NumHrsPreInsp, IPT_NumHrsdesloc, IPT_NumHrsInsp, IPT_DtUltAtu, IPT_UserName)
					values ('#rsUnidade.Und_Codigo#', '#rsInspecao.INP_NumInspecao#', '#i#', CONVERT(DATETIME, '#form.dataInicioInsp#', 103), CONVERT(DATETIME, '#form.dataFimInsp#', 103), CONVERT(DATETIME, '#form.dataInicioDesl#', 103), CONVERT(DATETIME, '#form.dataFimDesl#', 103), '#form.horasPreInspecao#', '#form.horasDeslocamento#', '#form.horasInspecao#', CONVERT(char, getdate(), 120), '#qAcesso.Usu_Matricula#')
				</cfquery>
			</cfloop>
			<!--- Tela pode alterar a partir de 22/01/2024 Gilvan --->
			<cfquery datasource="#dsn_inspecao#">
				UPDATE Inspetor_Inspecao SET 
					<cfif '#modalidade#' eq 0>
						IPT_NumHrsPreInsp = '#form.horasPreInspecao#',
						IPT_DtInicDesloc = CONVERT(DATETIME, '#form.dataInicioDesl#', 103),
						IPT_DtFimDesloc =  CONVERT(DATETIME, '#form.dataFimDesl#', 103),
						IPT_NumHrsdesloc=  '#form.horasDeslocamento#',
					<cfelse>
						IPT_NumHrsPreInsp = '1',	
						IPT_DtInicDesloc = CONVERT(DATETIME, '#form.dataInicioInsp#', 103),
						IPT_DtFimDesloc =  CONVERT(DATETIME, '#form.dataFimInsp#', 103),
						IPT_NumHrsDesloc = '1',
					</cfif>
					IPT_NumHrsInsp = '#form.horasInspecao#',
					IPT_DtInicInsp=  CONVERT(DATETIME, '#form.dataInicioInsp#', 103),
					IPT_DtFimInsp=  CONVERT(DATETIME, '#form.dataFimInsp#', 103), 
					IPT_DtUltAtu = CONVERT(char, getdate(), 120), 
					IPT_UserName = '#qAcesso.Usu_Matricula#'
				WHERE IPT_NumInspecao = convert(varchar,'#rsInspecao.INP_NumInspecao#') 
			</cfquery>
			<cfquery datasource="#dsn_inspecao#">
				UPDATE inspecao SET  
					<cfif '#modalidade#' eq 0>
						INP_HrsPreInspecao = '#form.horasPreInspecao#',
						INP_DtInicDeslocamento = CONVERT(DATETIME, '#form.dataInicioDesl#', 103),
						INP_DtFimDeslocamento =  CONVERT(DATETIME, '#form.dataFimDesl#', 103),
						INP_HrsDeslocamento=  '#form.horasDeslocamento#',
					<cfelse>
						INP_HrsPreInspecao = '1',
						INP_DtInicDeslocamento = CONVERT(DATETIME, '#form.dataInicioInsp#', 103),
						INP_DtFimDeslocamento =  CONVERT(DATETIME, '#form.dataFimInsp#', 103),	
						INP_HrsDeslocamento=  '1',				
					</cfif>
					INP_HrsInspecao = '#form.horasInspecao#',
					INP_DtInicInspecao=  CONVERT(DATETIME, '#form.dataInicioInsp#', 103),
					INP_DtFimInspecao=  CONVERT(DATETIME, '#form.dataFimInsp#', 103)
				WHERE INP_NumInspecao = convert(varchar,'#rsInspecao.INP_NumInspecao#') 
			</cfquery>
		</cftransaction> 
    </cfif>

	<cfquery datasource="#dsn_inspecao#" name="rsInspetores">
		SELECT Usu_Matricula, Usu_Apelido, Dir_Sigla, CASE WHEN Usu_Matricula = '#url.coordenador#' THEN '0' ELSE '1' END AS ordem FROM Usuarios 
		INNER JOIN Diretoria ON  Dir_Codigo = Usu_DR
		INNER JOIN Funcionarios ON Fun_Matric = Usu_Matricula
		WHERE Usu_GrupoAcesso='INSPETORES' and Usu_DR in(#se#)  and Usu_Matricula not in(SELECT IPT_MatricInspetor FROM Inspetor_Inspecao WHERE IPT_NumInspecao = convert(varchar,'#url.numInspecao#'))
		ORDER BY ordem ASC, Dir_Sigla ASC, Usu_Apelido ASC
	</cfquery>

	<cfquery datasource="#dsn_inspecao#" name="rsInspetoresCadastrados">
		SELECT Inspetor_Inspecao.*  FROM Inspetor_Inspecao 
		WHERE IPT_NumInspecao = '#url.numInspecao#'
	</cfquery>

    <!--- Rotina para finalização do cadastro da inspeção com a geração dos itens no status não avaliado --->


	<cfif isdefined('url.acao')>
		<cfif '#url.acao#' eq 'resumo'>
			<cfquery datasource="#dsn_inspecao#" name="qVerificaCoordenador">   
				SELECT IPT_MatricInspetor 
				FROM Inspetor_Inspecao 
				WHERE IPT_MatricInspetor=#url.coordenador# and IPT_NumInspecao =convert(varchar,'#url.numInspecao#')
			 </cfquery>
			 <cfif #qVerificaCoordenador.recordcount# eq 0>

				<cfquery datasource="#dsn_inspecao#" name="rsInspCaInsp">
					SELECT * FROM Inspecao 
					WHERE  left(INP_NumInspecao,2) in(#se#) 
					      and INP_NumInspecao = '#url.numInspecao#'
					      and INP_Situacao ='NA' 
				</cfquery>
			
				 
				</cfif>
		</cfif>

		<cfif '#url.acao#' eq 'finalizar'>
		  
		  
			<cftransaction> 
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
										INP_DtInicInspecao=      '#rsResumo.dtInicInspMin#',
										INP_DtFimInspecao=       '#rsResumo.dtFimInspMax#', 
										INP_HrsInspecao =        '#rsResumo.numHrsInspTotal#',
										INP_Situacao =           'NA',
										INP_DtUltAtu =           convert(char,getdate(), 120),
                                        INP_UserName =           '#qAcesso.Usu_Login#'
					WHERE INP_NumInspecao = convert(varchar,'#url.numInspecao#') 
				</cfquery>

				<cfquery datasource="#dsn_inspecao#">
					UPDATE Numera_Inspecao SET NIP_Situacao ='A' WHERE NIP_NumInspecao = convert(varchar,'#url.numInspecao#') 
				</cfquery>
                
				<cfquery datasource="#dsn_inspecao#" name="rsItens">
					SELECT * 
					FROM Itens_Verificacao INNER JOIN TipoUnidade_ItemVerificacao ON (Itn_NumItem = TUI_ItemVerif) AND (Itn_NumGrupo = TUI_GrupoItem) AND (Itn_TipoUnidade = TUI_TipoUnid) AND 
					(Itn_Modalidade = TUI_Modalidade) AND (Itn_Ano = TUI_Ano)
					WHERE TUI_Modalidade ='#modalidade#' 
					and TUI_Ano=year('#rsInspecao.INP_DtInicInspecao#') 
					and TUI_TipoUnid='#rsUnidade.Und_TipoUnidade#'
					and TUI_Ativo = 1
				</cfquery>
				<cfset auxvlr = '0.00'>
				<cfoutput query="rsItens">
				    <cfset RIPCaractvlr = 'NAO QUANTIFICADO'>
					<cfif listfind('#rsItens.TUI_Pontuacao_Seq#','10')>
					 <cfset RIPCaractvlr = 'QUANTIFICADO'>
					</cfif>
				     
				    <cfquery datasource="#dsn_inspecao#">
					    INSERT INTO Resultado_Inspecao (RIP_Unidade, RIP_NumInspecao, RIP_NumGrupo, RIP_NumItem, RIP_CodDiretoria, RIP_CodReop, RIP_Ano, RIP_Resposta, RIP_Comentario, RIP_DtUltAtu, RIP_UserName, RIP_Caractvlr, RIP_Falta, RIP_Sobra, RIP_EmRisco,RIP_Manchete) 
					    VALUES ('#rsUnidade.Und_Codigo#', '#url.numInspecao#', #TUI_GrupoItem#, #TUI_ItemVerif#, '#rsUnidade.Und_CodDiretoria#', '#rsUnidade.Und_CodReop#', #TUI_Ano#, 'A', '', CONVERT(char, GETDATE(), 120), '#qAcesso.Usu_Matricula#','#RIPCaractvlr#',#auxvlr#,#auxvlr#,#auxvlr#,'#rsItens.Itn_Manchete#')
					</cfquery>
				</cfoutput>
			</cftransaction> 
                <cfquery datasource="#dsn_inspecao#" name="rsInspecao">
					SELECT * FROM Inspecao WHERE INP_NumInspecao = '#url.numInspecao#' and INP_Situacao='NA'
				</cfquery>
				
				<cflocation url = "cadastro_inspecao_inspetores.cfm?acao=finalizado&modalidade=#modalidade#" addToken = "no">
	
			</cfif>

		
		  
	      
	    </cfif>		

</cfif>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>SNCI - CADASTRO DE AVALIAÇÕES</title>


<link rel="stylesheet" type="text/css" href="view.css" media="all">

	<!--- <link href="css.css" rel="stylesheet" type="text/css"> --->



<script type="text/javascript">
<cfoutput><cfparam name="URL.acao" default=""></cfoutput>

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


function aguarde(){
	if(document.getElementById("aguarde").style.visibility == "visible"){
       document.getElementById("aguarde").style.visibility = "hidden";
	}else{
	   document.getElementById("aguarde").style.visibility = "visible";	
	   piscando();
	}
 }
 function aguardeFinaliza(){
	if(document.getElementById("aguardeFinaliza").style.visibility == "visible"){
       document.getElementById("aguardeFinaliza").style.visibility = "hidden"
	}else{
	   document.getElementById("aguardeFinaliza").style.visibility = "visible"	
	}
 }
 

function verifQuantInspetores(a,b) {

<cfif isdefined('url.numInspecao')	>
	<cfquery datasource="#dsn_inspecao#" name="rsInspCadast">
		SELECT IPT_MatricInspetor FROM Inspetor_Inspecao WHERE IPT_NumInspecao = '#url.numInspecao#'
	</cfquery>
	<cfquery datasource="#dsn_inspecao#" name="rsVerifCadCoord">
		SELECT IPT_MatricInspetor FROM Inspetor_Inspecao WHERE IPT_NumInspecao = '#url.numInspecao#' and IPT_MatricInspetor = '#url.coordenador#'
	</cfquery>
	<cfquery datasource="#dsn_inspecao#" name="rsNomeCoordenador">
		SELECT Fun_Matric, Fun_Nome FROM Funcionarios WHERE Fun_Matric = '#url.coordenador#'
	</cfquery>

	var quant =<cfoutput>'#rsInspCadast.recordcount#'</cfoutput>;
	var temCoord =<cfoutput>'#rsVerifCadCoord.recordcount#'</cfoutput>;
	var mens ='Cadastre o coordenador desta verificação!\n<cfoutput>#rsNomeCoordenador.Fun_Nome#</cfoutput>';
	if(quant == '1'){
		alert('Cadastre, pelo menos, dois inspetores!');	
		return false;
	}
	if(temCoord == '0'){
		alert(mens);	
		return false;
	}
	resumoCadastro(<cfoutput>'#url.NumInspecao#','#url.coordenador#'</cfoutput>);
</cfif>
}

 function valida_formCadInsp() {
    var frm = document.forms[1];

    if (frm.selInspetores.value == '') {
    	alert('Selecione, pelo menos, um inspetor na lista!');
    	frm.selInspetores.focus();
    	return false;
    }

}
//================
function excluirInspetor(){
	if (confirm ("Deseja Excluir?")){}
				else{
					return false;
					}
}

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
		if ((tecla != 46) && ((tecla < 48) || (tecla > 57))) {
		event.returnValue = false;
	}
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

function resumoCadastro(insp,coord){
   var caminho = 'cadastro_inspecao_inspetores.cfm?numInspecao=' + insp +'&coordenador=' + coord + '&acao=resumo' +'#resumo';
   window.location.href = caminho;
	//window.location.href(caminho);
}
function finalizarCadastro(insp,coord){
   var caminho = 'cadastro_inspecao_inspetores.cfm?numInspecao=' + insp +'&coordenador=' + coord + '&acao=finalizar';
 //  var mensagem ="ATENÇÃO!\n\nApós finalização do cadastro desta Avaliação, caso haja algum erro, ela deverá ser excluída (Cadastro de Avaliações -> Tabela 'Avaliações com Cadastro Finalizado') e recadastrada (neste caso, o n° de Avaliação " + insp + " pode não ser mais utilizado).\n\nVocê conferiu os dados desse cadastro e deseja finalizá-lo?";
//   if (window.confirm(mensagem)) {
//	  aguardeFinaliza(); 
	window.location.href = caminho;
//	  window.location.href(caminho);
 //  }
}

//================
function valida_formCadNum() {
    var frm = document.forms[0];
	var mod ="";
    <cfoutput><cfif isDefined("url.numInspecao")>mod = '#modalidade#'</cfif></cfoutput>;
	
    if (frm.selInspetores.value == '') {
    	alert('Selecione, pelo menos, um inspetor na lista!');
    	frm.selInspetores.focus();
    	return false;
    }
	
	function gerarData(str) {
		var partes = str.split("/");
		return new Date(partes[2], partes[1] - 1, partes[0]);
    }
    var d = new Date();
	d.setHours(0,0,0,0);
	if(d > gerarData(frm.dataInicioDesl.value) && mod == 0){
		alert('A data de início do deslocamento não pode ser menor que a data de hoje.')
		frm.dataInicioDesl.focus();
		frm.dataInicioDesl.select();
		return false;
	}

	var dataInicioDesl =gerarData(frm.dataInicioDesl.value) ;
	var dataFimDesl =gerarData(frm.dataFimDesl.value) ;
	if(dataInicioDesl > dataFimDesl && mod == 0){
		alert('A data de fim do deslocamento não pode ser menor que a data de início do deslocamento.')
		frm.dataFimDesl.focus();
		frm.dataFimDesl.select();
		return false;
	}

    var dataInicioInsp =gerarData(frm.dataInicioInsp.value) ;
	var dataFimDesl =gerarData(frm.dataFimDesl.value) ;
	if(dataFimDesl < dataInicioInsp && mod == 0){
		alert('A data de início da verificação não pode ser maior que a data de fim do deslocamento.')
		frm.dataInicioInsp.focus();
		frm.dataInicioInsp.select();
		return false;
	}

	var dataInicioInsp =gerarData(frm.dataInicioInsp.value) ;
	var dataFimInsp =gerarData(frm.dataFimInsp.value) ;
	if(dataInicioInsp > dataFimInsp && mod == 0){
		alert('A data de fim da verificação não pode ser menor que a data de início da verificação.')
		frm.dataFimInsp.focus();
		frm.dataFimInsp.select();
		return false;
	}


	var dataFimDesl =gerarData(frm.dataFimDesl.value) ;
	var dataFimInsp =gerarData(frm.dataFimInsp.value) ;
	if(dataFimInsp > dataFimDesl && mod == 0){
		alert('A data de fim da verificação não pode ser maior que a data de fim do deslocamento.')
		frm.dataFimInsp.focus();
		frm.dataFimInsp.select();
		return false;
	}



	var dataInicioInsp =gerarData(frm.dataInicioInsp.value) ;
	var dataInicioDesl =gerarData(frm.dataInicioDesl.value) ;
	if(dataInicioInsp < dataInicioDesl && mod == 0){
		alert('A data de inicio da verificação não pode ser menor que a data de início do deslocamento.')
		frm.dataInicioInsp.focus();
		frm.dataInicioInsp.select();
		return false;
	}


    if(mod==0){
      if (frm.dataInicioDesl.value == '') {
    	alert('Informe a data inicial do deslocamento!');
    	frm.dataInicioDesl.focus();
    	return false;
      }

      if (frm.dataFimDesl.value == '') {
    	alert('Informe a data final do deslocamento!');
    	frm.dataFimDesl.focus();
    	return false;
      }
	}else{
		
		if (frm.dataInicioDesl.value != '' && frm.dataFimDesl.value == '') {
			alert('Informe a data final do deslocamento!');
			frm.dataFimDesl.focus();
			return false;
		}
		if (frm.dataInicioDesl.value == '' && frm.dataFimDesl.value != '') {
			alert('Informe a data inicial do deslocamento!');
    	    frm.dataInicioDesl.focus();
    	    return false;
		}
	}
	

	if (frm.dataInicioInsp.value == '') {
    	alert('Informe a data inicial da verificação!');
    	frm.dataInicioInsp.focus();
    	return false;
    }
    if (frm.dataFimInsp.value == '') {
    	alert('Informe a data final da verificação!');
    	frm.dataFimInsp.focus();
    	return false;
    }

	if(mod == 0){
		if (frm.horasPreInspecao.value == '' || frm.horasPreInspecao.value == '0') {
			alert('Informe a quantidade de horas utilizadas na Pré-Avaliação!');
			frm.horasPreInspecao.focus();
			frm.horasPreInspecao.select();
			return false;
		}
	}
    if(mod == 0){
		if (frm.horasDeslocamento.value == '' || frm.horasDeslocamento.value == '0' ) {
			alert('Em verificações na modalidade "PRESENCIAL" a quantidade de horas de deslocamento não pode estar vazia ou ser zero.');
			frm.horasDeslocamento.focus();
			frm.horasDeslocamento.select();
			return false;
		}
	}else{ 
		/* 
		if (frm.dataInicioDesl.value == '' && frm.horasDeslocamento.value > '0') {	
           alert('O campo "Horas Deslocamento" foi definido com valor maior que zero porém, a data de deslocamento está vazia.\nDefina o campo "Horas Deslocamento" como zero ou informe o período de deslocamento.') ;
		   frm.horasDeslocamento.focus();
		   frm.horasDeslocamento.select();
		   return false;
		}	

		if (frm.dataInicioDesl.value != '' && (frm.horasDeslocamento.value == '0'|| frm.horasDeslocamento.value == '')) {	
           alert('Um período de deslocamento foi informado, portanto, o campo "Horas Deslocamento" não pode estar vazio ou ser zero.') ;
		   frm.horasDeslocamento.focus();
		   frm.horasDeslocamento.select();
		   return false;
		}	
    
		if (frm.horasDeslocamento.value > '0' && frm.horasDeslocamento.readOnly == false ) {
			if(window.confirm('Esta verificação está na modalidade "A DISTÂNCIA".\nConfirma que ocorreu deslocamento?')){
			}else{
				frm.horasDeslocamento.focus();
				frm.horasDeslocamento.select();
				return false;
			}
		}
		*/
	}

	if (frm.dataInicioInsp.value == '') {
    	alert('Informe a data de inicio da Avaliação!');
    	frm.dataInicioInsp.focus();
    	return false;
    }
	if (frm.dataFimInsp.value == '') {
    	alert('Informe a data final da Avaliação!');
    	frm.dataFimInsp.focus();
    	return false;
    }

	if (frm.horasInspecao.value == '' || frm.horasInspecao.value == '0' ) {
    	alert('Informe a quantidade de horas utilizadas na Avaliação!');
    	frm.horasInspecao.focus();
		frm.horasInspecao.select();
    	return false;
    }

	if(window.confirm("Confirma o cadastro do(s) inspetor(es) selecionado(s)?")){
		aguarde();
	}else{
		return false;
	}
    
 }

	</script>

</head>
<body id="main_body">
<div id="aguarde" name="aguarde" align="center"  style="width:100%;height:100%;top:0px;left:0px; background:transparent;filter:progid:DXImageTransform.Microsoft.gradient(startColorstr=#7F86b2ff,endColorstr=#7F86b2ff);z-index:10000;visibility:hidden;position:absolute;" >		
				<img i="imagAguarde" name="imgAguarde"" src="figuras/aguarde.png" width="100px"  border="0" style="position:relative;top:200px"></img>
		    </div>
	<!--- <cfinclude template="cabecalho.cfm"> --->
	<div align="left" style="margin:10px">
		
	<a href="cadastro_inspecao.cfm" onClick="aguarde();" class="botaoCad" style="position:relative;left:13px;"><img src="figuras/voltar.png" width="25"  border="0" style="position:absolute;left:5px;top:3px"></img>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Voltar ao Cadastro Inicial</a>
	</div>

	

	
	<cfif isdefined('url.acao')>
		<cfif '#url.acao#' neq 'resumo' and '#url.acao#' neq 'finalizado'>

	<cfif isDefined("url.numInspecao")>
		
		<br>
	
	   	<div id="form_container" style="position:relative;">
			
			<a id="formCad"></a>
			
			<h1 style="font-size:20px">
				<img src="figuras/usuario.png" width="55"  border="0" style="position:absolute;"></img>
				<div align="center"> Cadastro de Inspetores - Avaliação n° <cfoutput><strong>#url.numInspecao#</strong></cfoutput>
					<br>
					<cfquery datasource="#dsn_inspecao#" name="rsUnidadeSelecionada">
						SELECT Und_Codigo, Und_Descricao,Dir_Sigla FROM Unidades 
						INNER JOIN Diretoria ON  Dir_Codigo = Und_CodDiretoria
						WHERE Und_Status='A' and Und_Codigo	='#rsInspecao.INP_Unidade#'
					</cfquery>
					<cfquery name="rsCoordenador2" datasource="#dsn_inspecao#">
						select Usu_Matricula, Usu_Apelido, Dir_Sigla from usuarios 
						INNER JOIN Diretoria ON  Dir_Codigo =Usu_DR
						where Usu_Matricula = Convert(varchar,#url.Coordenador#)
					</cfquery>
					<cfquery datasource="#dsn_inspecao#" name="rsNumeraInspecao2">
						SELECT NIP_DtIniPrev FROM Numera_Inspecao WHERE NIP_NumInspecao=convert(varchar,'#url.NumInspecao#') 
						AND NIP_Situacao='P'
					</cfquery>
                     <cfset dtIniPrev = dateformat("#rsNumeraInspecao2.NIP_DtIniPrev#",'dd/mm/yyyy')>
					<label style="font-size:14px;">
							<cfoutput>
								#trim(rsUnidadeSelecionada.Dir_Sigla)# - #trim(rsUnidadeSelecionada.Und_Descricao)# (#trim(rsUnidadeSelecionada.Und_Codigo)#) - Mod.: <cfif '#modalidade#' eq 0>
									PRESENCIAL<cfelse>A DISTÂNCIA</cfif>
							</cfoutput>
					</label>
					<br>
					<label style="font-size:12px;">
						<cfoutput>
							Coord.: #rsCoordenador2.Usu_Apelido# (#trim(rsCoordenador2.Dir_Sigla)#) - Data Prev.: #dtIniPrev#
						</cfoutput>
				</label>
				</div>
			</h1>
			<br><br>
			<!--- xxxxxxxxxxxxxxxxxxxxxx Form CadInspetores xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
			<cfquery datasource="#dsn_inspecao#" name="rsInspCadast">
				SELECT IPT_MatricInspetor FROM Inspetor_Inspecao WHERE IPT_NumInspecao = '#url.numInspecao#'
			</cfquery>
			<form id="formCadNum" nome="formCadNum" class="appnitro" style="position:relative;top:-20px"
				onSubmit="return valida_formCadNum()" enctype="multipart/form-data" method="post"
				action="cadastro_inspecao_inspetores.cfm?<cfoutput>
															numInspecao=#url.NumInspecao#
															&coordenador=#url.coordenador#
															&dtInicDeslocamento=#url.dtInicDeslocamento#
															&dtFimDeslocamento=#url.dtFimDeslocamento#
															&dtInicInspecao=#url.dtInicInspecao#
															&dtFimInspecao=#url.dtFimInspecao#
														</cfoutput>
														#tabInsp">

				<cfif isDefined("url.numInspecao")>
					<cfquery datasource="#dsn_inspecao#" name="rsInspecao">
							SELECT * FROM Inspecao WHERE INP_NumInspecao = '#url.numInspecao#' and INP_Situacao='NA'
					</cfquery>
				</cfif>	

				<div align:"center" style="position:relative;left:50px">	
					<tr>
						<td>
							<label for="selInspetores" style="color:grey">Selecione um ou mais Inspetores:  </label>
							<br>
							<select multiple name="selInspetores" id="selInspetores" class="form" style="width:500px;height:80px">
								<cfoutput query="rsInspetores">
									<option  <cfif  '#trim(Usu_Matricula)#' eq '#url.coordenador#' >selected</cfif> value="#trim(Usu_Matricula)#"><cfif  '#trim(Usu_Matricula)#' eq '#url.coordenador#' >Coord.: </cfif>#trim(Dir_Sigla)# - #trim(Usu_Apelido)#</option>
								</cfoutput>
							</select><br><span style="font-size:11px;color:cadetblue;position:absolute;top:100px">Mantenha pressionada a tecla "CTRL" para selecionar mais de um inspetor.</span>
						</td>
					</tr>
				</div>	
					<br>
				<div style="WIDTH: 202px; RIGHT:18px;POSITION: absolute; PADDING: 5px;TOP:125px;BACKGROUND-COLOR:#fff;border:1px solid #e0dddd">
					<span style="color:gray;font-size:14px;position:absolute;top:-19px;left:0px">Carga Horária (por inspetor):</span>
					<tr>
					<td>
						<cfquery datasource="#dsn_inspecao#" name="rsInspCadastrados">
							SELECT IPT_MatricInspetor FROM Inspetor_Inspecao WHERE IPT_NumInspecao = '#url.numInspecao#'
						</cfquery>
						<label for="horasPreInspecao" style="color:gray">Horas Pré-Avaliação:</label>
<!---						<input id="horasPreInspecao" name="horasPreInspecao" type="text" 
						    value="<cfoutput><cfif isDefined("url.numInspecao") and '#modalidade#' eq '0'>#rsInspetoresCadastrados.IPT_NumHrsPreInsp#<cfelse>0</cfif></cfoutput>" 
							onKeyPress="numericos()" maxlength="2" 	style="width:20px;text-align:center;margin-left:3px;border:1px solid #e0dddd"
							
								<cfif isDefined("url.numInspecao") and '#modalidade#' eq '1'>
									style="background:#eef1f3;text-align:center;"
									readonly
								</cfif>	
								<cfif isDefined("url.numInspecao") and '#rsInspCadastrados.recordcount#' gte '1'>
									style="background:#eef1f3;text-align:center;"
									readonly
								</cfif>
--->
						<input id="horasPreInspecao" name="horasPreInspecao" type="text" 
						    value="<cfoutput><cfif isDefined("url.numInspecao") and '#modalidade#' eq '0'>#rsInspetoresCadastrados.IPT_NumHrsPreInsp#<cfelse>0</cfif></cfoutput>" 
							onKeyPress="numericos()" maxlength="2" 	style="width:20px;text-align:center;margin-left:3px;border:1px solid #e0dddd"/>
					</td>
					<br>
					<td>
						<label for="horasDeslocamento" style="color:gray">Horas Deslocamento:</label>
<!---						<input id="horasDeslocamento" name="horasDeslocamento" type="text" 
						value="<cfoutput><cfif isDefined("url.numInspecao")>#rsInspetoresCadastrados.IPT_NumHrsDesloc#</cfif></cfoutput>"
						style="width:20px;text-align:center;margin-left:0px;border:1px solid #e0dddd" onKeyPress="numericos()" maxlength="2" 
						<cfif isDefined("url.numInspecao") and '#rsInspCadastrados.recordcount#' gte '1'>
							style="background:#eef1f3;"
							readonly
						</cfif>
--->
						<input id="horasDeslocamento" name="horasDeslocamento" type="text" 
						value="<cfoutput><cfif isDefined("url.numInspecao")>#rsInspetoresCadastrados.IPT_NumHrsDesloc#</cfif></cfoutput>"
						style="width:20px;text-align:center;margin-left:0px;border:1px solid #e0dddd" onKeyPress="numericos()" maxlength="2"/>
					</td>
					<br>
					<td>
						<label for="horasInspecao" style="color:gray">Horas Avaliação:
							&nbsp;&nbsp;&nbsp;&nbsp;</label>
<!---						<input id="horasInspecao" name="horasInspecao" type="text" 
						value="<cfoutput><cfif isDefined("url.numInspecao")>#rsInspetoresCadastrados.IPT_NumHrsInsp#</cfif></cfoutput>" style="border:1px solid #e0dddd;width:20px;text-align:center;margin-left:7px"
							onKeyPress="numericos()" maxlength="2" 
							<cfif isDefined("url.numInspecao") and '#rsInspCadastrados.recordcount#' gte '1'>
								style="background:#eef1f3;"
								readonly
							</cfif>
--->
						<input id="horasInspecao" name="horasInspecao" type="text" 
						value="<cfoutput><cfif isDefined("url.numInspecao")>#rsInspetoresCadastrados.IPT_NumHrsInsp#</cfif></cfoutput>" style="border:1px solid #e0dddd;width:20px;text-align:center;margin-left:7px"
							onKeyPress="numericos()" maxlength="2"/>

					</td>
				  </tr>
				</div>
					<br>
				<div style="background:#fff;padding:1px;padding-top:6px;position:relative;top:-5px;height:60px;width:440px;border:1px solid #e0dddd">
				<span style="color:gray;font-size:14px;position:absolute;top:-19px;left:0px">Datas.:</span>
				<tr>
					<td>
						<label for="dataInicioDesl" style="color:gray">Início Desloc.:&nbsp;&nbsp;</label>
						<cfset dataInicioDesl ="">
						<cfif isDefined("url.numInspecao") and isdefined('form.dataInicioDesl') and '#form.dataInicioDesl#' neq ''></cfif>
						  <cfset dataInicioDesl ='#DateFormat(rsInspetoresCadastrados.IPT_DtInicDesloc,"dd/mm/yyyy")#'>
						
<!---						<input id="dataInicioDesl" name="dataInicioDesl" type="text" value="<cfoutput>#dataInicioDesl#</cfoutput>" style="width:82px;border:1px solid #e0dddd"
							onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" size="14" maxlength="10" <cfif '#rsInspetoresCadastrados.IPT_DtInicDesloc#' eq '1900/1/1' or '#dataInicioDesl#' neq ''>style="background:#eef1f3;" readonly</cfif>/>
--->
						<input id="dataInicioDesl" name="dataInicioDesl" type="text" value="<cfoutput>#dataInicioDesl#</cfoutput>" style="width:82px;border:1px solid #e0dddd"
							onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" size="14" maxlength="10">
					</td>

					<td colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp</td>

					<td>
						<label for="dataFimDesl" style="color:gray">Fim Desloc.:&nbsp;&nbsp;&nbsp;</label>
						<cfset dataFimDesl ="">
						<cfif isDefined("url.numInspecao") and isdefined('form.dataFimDesl') and '#form.dataFimDesl#' neq ''></cfif>
						  <cfset dataFimDesl ='#DateFormat(rsInspetoresCadastrados.IPT_DtFimDesloc,"dd/mm/yyyy")#'>
						
<!---						<input id="dataFimDesl" name="dataFimDesl" type="text" value="<cfoutput>#dataFimDesl#</cfoutput>" style="width:82px;border:1px solid #e0dddd"
							onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" size="14" maxlength="10" <cfif '#rsInspetoresCadastrados.IPT_DtInicDesloc#' eq '1900/1/1' or '#dataFimDesl#' neq ''>style="background:#eef1f3;" readonly</cfif>/>
--->						
<input id="dataFimDesl" name="dataFimDesl" type="text" value="<cfoutput>#dataFimDesl#</cfoutput>" style="width:82px;border:1px solid #e0dddd"
							onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" size="14" maxlength="10">	
					</td>

					
				</tr>

				<br><br>
				<tr>
					<td>
						<label for="dataInicioInsp" style="color:gray">Início Aval.:&nbsp;&nbsp;&nbsp;&nbsp;</label>
						<cfset dataInicioInsp ="">
						<cfif isDefined("url.numInspecao")>
						  <cfset dataInicioInsp ='#DateFormat(rsInspetoresCadastrados.IPT_DtInicInsp,"dd/mm/yyyy")#'>
						</cfif>
<!---						<input id="dataInicioInsp" name="dataInicioInsp" type="text" value="<cfoutput>#dataInicioInsp#</cfoutput>" style="width:82px;border:1px solid #e0dddd;margin-left:5px"
							onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" size="14" maxlength="10" <cfif '#dataInicioInsp#' neq ''>style="background:#eef1f3;" readonly</cfif>/>
--->
							<input id="dataInicioInsp" name="dataInicioInsp" type="text" value="<cfoutput>#dataInicioInsp#</cfoutput>" style="width:82px;border:1px solid #e0dddd;margin-left:5px"
							onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" size="14" maxlength="10">						
					</td>

					<td colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>

					<td>
						<label for="dataFimInsp" style="color:gray">Fim Aval.:&nbsp;&nbsp;&nbsp;</label>
						<cfset dataFimInsp ="">
						<cfif isDefined("url.numInspecao")>
						  <cfset dataFimInsp ='#DateFormat(rsInspetoresCadastrados.IPT_DtFimInsp,"dd/mm/yyyy")#'>
						</cfif>
<!---						<input id="dataFimInsp" name="dataFimInsp" type="text" value="<cfoutput>#dataFimInsp#</cfoutput>" style="width:82px;border:1px solid #e0dddd;margin-left:13px"
							onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" size="14" maxlength="10" <cfif '#dataFimInsp#' neq ''>style="background:#eef1f3;" readonly</cfif>/>
--->
						<input id="dataFimInsp" name="dataFimInsp" type="text" value="<cfoutput>#dataFimInsp#</cfoutput>" style="width:82px;border:1px solid #e0dddd;margin-left:13px"
							onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" size="14" maxlength="10">
					</td>

					
				</tr>

				</div>	
			
				<br>
				<div align="center">
				
						<a name="btCadastrar" onClick="return valida_formCadNum()" id="btCadastrar" href="javascript:formCadNum.submit()"
									class="botaoCad" style="position:relative;left:13px;"><img src="figuras/usuario.png" width="25"  
									border="0" style="position:absolute;left:0px;top:5px">
								</img>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Clique para Cadastrar</a>
	
				</div>
				
				
			</form>
			
		</div>
	
		<cfif rsInspetoresCadastrados.recordCount neq 0>
			
			<div id="form_container" style="position:relative;top:-25px">
				<table width="720px" border="0" align="center">
					
					
					
					<tr bgcolor="write">
						<td colspan="8" align="center" class="titulos">
							<h1 style="font-size:14px">INSPETORES CADASTRADOS</h1>
						</td>
					</tr>

					<tr bgcolor="#6699CC" class="exibir" align="center" style="color:#fff">
						<td width="7%">
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
						<td width="5%">
							<div align="center">Excluir</div>
						</td>

					</tr>
					<tr>

						<cfset scor='white'>
							<cfoutput query="rsInspetoresCadastrados">
								<form action="" method="POST" name="formexc">
									<cfquery datasource="#dsn_inspecao#" name="nomeInspCad">
										SELECT Usu_Apelido, Dir_Sigla FROM usuarios 
										INNER JOIN Diretoria ON  Dir_Codigo = Usu_DR
										WHERE Usu_Matricula =
										convert(varchar,#IPT_MatricInspetor#)
									</cfquery>
<!---							<cfif isdefined('form.dataInicioDesl') and '#form.dataInicioDesl#' neq "">	
									<cfset perDesloc='#DateFormat(IPT_DtInicDesloc,' dd/mm/yyyy')#' & ' a '
										& '#DateFormat(IPT_DtFimDesloc,' dd/mm/yyyy')#'> 
								<cfelse>
									<cfset perDesloc="não houve">
                                </cfif>
--->
								<cfset perDesloc='#DateFormat(IPT_DtInicDesloc,' dd/mm/yyyy')#' & ' a '
										& '#DateFormat(IPT_DtFimDesloc,' dd/mm/yyyy')#'> 
														

								<cfset	perInspec='#DateFormat(IPT_DtInicInsp,' dd/mm/yyyy')#' & ' a '
										& '#DateFormat(IPT_DtFimInsp,' dd/mm/yyyy')#'> 

								<tr valign="middle"		bgcolor="#scor#" class="exibir">
										<td width="6%">
											<div align="center">#IPT_MatricInspetor#</div>
										</td>
										<td width="20%">
											<div align="left">#trim(nomeInspCad.Usu_Apelido)# (#trim(nomeInspCad.Dir_Sigla)#)</div>
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
										<td width="5%">
											<div align="center"><a
													onclick="return confirm('Confirma a exclusão deste Inspetor como participante desta Inspeção? \n#trim(nomeInspCad.Usu_Apelido)#')"
													href="cadastro_inspecao_inspetores.cfm?numInspecao=#IPT_NumInspecao#&numMatricula=#IPT_MatricInspetor#&coordenador=#url.Coordenador#&dtInicDeslocamento=#url.dtInicDeslocamento#&dtFimDeslocamento=#url.dtFimDeslocamento#&dtInicInspecao=#url.dtInicInspecao#&dtFimInspecao=#url.dtFimInspecao#&acao=excInspetor"><img
														src="icones/lixeiraRosa.png" width="15" height="15" border="0"></img></a></div>
										</td>
					</tr>

					</form>

					<cfif scor eq 'white'>
						<cfset scor='f7f7f7'>
							<cfelse>
								<cfset scor='white'>
					</cfif>
					</cfoutput>


		</cfif>

		</table>
		<cfif rsInspetoresCadastrados.recordCount neq 0>
			<cfquery datasource="#dsn_inspecao#" name="rsUnidades">
				SELECT Und_Codigo, Und_Descricao FROM Unidades WHERE Und_Status='A' and Und_Codigo ='#rsInspecoes.INP_Unidade#'
			</cfquery>

			<cfset inspecaoTexto="#url.NumInspecao# - #trim(rsUnidades.Und_Descricao)# (#rsUnidades.Und_Codigo#)">

				<div align="center">
					<a  onclick="verifQuantInspetores(<cfoutput>'#url.NumInspecao#','#url.coordenador#'</cfoutput>);"  href="#"
						class="botaoCad" style="position:relative;left:13px;top:0px"><img src="figuras/cadastro.png" width="25"  
						border="0" style="position:absolute;left:0px;top:5px">
						</img>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Clique para Conferir e finalizar o Cadastro desta Avaliação</a>
				</div>
		</cfif>
				</div>
				</div>
				
				<a id="tabInsp"></a>

  </cfif>

</cfif>

<cfif '#url.acao#' eq 'resumo' >
<!---#######################Resumo da Finalização do Cadastramento##################---->
<br><br>
<div id="form_container" style="position:relative;top:-35px">
	<div id="aguardeFinaliza" name="aguardeFinaliza" align="center"  style="width:100%;height:266px;top:0px;left:0px; background:transparent;filter:progid:DXImageTransform.Microsoft.gradient(startColorstr=#7F86b2ff,endColorstr=#7F86b2ff);z-index:10000;visibility:hidden;position:absolute;" >		
		<img src="figuras/aguarde.png" width="10%"  border="0" style="position:relative;top:40%"></img>
	</div>
	<a id="resumo"></a>
	<h1 style="font-size:20px">
		<img src="figuras/cadastro.png" width="55"  border="0" style="position:absolute"></img>
		<div align="center"> Resumo do Cadastro da Avaliação n° <cfoutput><strong>#url.numInspecao#</strong>

		</cfoutput>
		<br>
		<cfquery datasource="#dsn_inspecao#" name="rsUnidadeSelecionada">
						SELECT Und_Codigo, Und_Descricao,Dir_Sigla FROM Unidades 
						INNER JOIN Diretoria ON  Dir_Codigo = Und_CodDiretoria
						WHERE Und_Status='A' and Und_Codigo	='#rsInspecao.INP_Unidade#'
		</cfquery>
		<cfquery name="rsCoordenador2" datasource="#dsn_inspecao#">
			select Usu_Matricula, Usu_Apelido,Dir_Sigla from usuarios 
			INNER JOIN Diretoria ON  Dir_Codigo = Usu_DR
			where Usu_Matricula = Convert(varchar,#url.Coordenador#)
		</cfquery>
		<cfquery datasource="#dsn_inspecao#" name="rsNumeraInspecao2">
			SELECT NIP_DtIniPrev FROM Numera_Inspecao WHERE NIP_NumInspecao=convert(varchar,'#url.NumInspecao#') AND NIP_Situacao='P'
		</cfquery>
		 <cfset dtIniPrev = dateformat("#rsNumeraInspecao2.NIP_DtIniPrev#",'dd/mm/yyyy')>
		<label style="font-size:14px;">
				<cfoutput>
					#trim(rsUnidadeSelecionada.Dir_Sigla)# - #trim(rsUnidadeSelecionada.Und_Descricao)# (#trim(rsUnidadeSelecionada.Und_Codigo)#) - Mod.: <cfif '#modalidade#' eq 0>
						PRESENCIAL<cfelse>A DISTÂNCIA</cfif>
				</cfoutput>
		</label>
		<br>
		<label style="font-size:12px;">
			<cfoutput>
				Coord.: #rsCoordenador2.Usu_Apelido# (#trim(rsCoordenador2.Dir_Sigla)#) - Data Prev.: #dtIniPrev#
			</cfoutput>
	    </label></h1>
		<br>	

	

		<cfquery datasource="#dsn_inspecao#" name="rsResumo">
			SELECT min(IPT_DtInicDesloc)  as dtInicDeslocMin, 
				   max(IPT_DtFimDesloc)   as dtFimDesloclMax,
				   min(IPT_DtInicInsp)    as dtInicInspMin, 
				   max(IPT_DtFimInsp)     as dtFimInspMax,
				   SUM(IPT_NumHrsPreInsp) as numHrsPreInspTotal,
				   MAX(IPT_NumHrsDesloc)  as numHrsDeslocTotal,
				   SUM(IPT_NumHrsInsp)    as numHrsInspTotal
			FROM Inspetor_Inspecao WHERE IPT_NumInspecao = '#url.numInspecao#'
		</cfquery>
       <cfif '#rsResumo.dtInicDeslocMin#' neq "1900/1/1">	
		    <cfset deslocamento=dateFormat('#rsResumo.dtInicDeslocMin#','dd/mm/yyyy') & ' a ' &
			                   dateFormat('#rsResumo.dtFimDesloclMax#','dd/mm/yyyy')> 
		<cfelse>
			<cfset deslocamento="não houve">			   
		</cfif>
		<cfset inspecao=dateFormat('#rsResumo.dtInicInspMin#','dd/mm/yyyy') & ' a ' &
			dateFormat('#rsResumo.dtFimInspMax#','dd/mm/yyyy')> 

	<div align="left" style="width:70%;position:relative;top:-80px">
			<table>
				<tr>
					<td>
						<label>Período de Deslocamento: </label>
					</td>

					<td>
						<label style="color:blue;">
							<cfoutput>#deslocamento#</cfoutput>
						</label>
					</td>
				</tr>
				<br>

				<tr>
					<td>
						<label>Período da Avaliação: </label>
					</td>
					<td>
						<label style="color:blue;">
							<cfoutput>#inspecao#</cfoutput>
						</label>
					</td>
				</tr>
				<br>
				<tr>
					<td>
						<label>Total Horas Pré-Avaliação: </label>
					</td>
					<td>
						<label style="color:blue;">
							<cfoutput>#rsResumo.numHrsPreInspTotal#h</cfoutput>
						</label>
					</td>
				</tr>

				<br>
				<tr>
					<td>
						<label>Total Horas Deslocamento:</label>
					</td>
					<td>
						<label style="color:blue;">
							<cfoutput>#rsResumo.numHrsDeslocTotal#h</cfoutput>
						</label>
					</td>
				</tr>
				<br>

				<tr>
					<td>
						<label>Total Horas Avaliação:</label>
					</td>
					<td>
						<label style="color:blue;">
							<cfoutput>#rsResumo.numHrsInspTotal#h</cfoutput>
						</label>
					</td>
				</tr>
			</table>
					<div align="center" style="margin-bottom:20px">
					<a  onclick="finalizarCadastro(<cfoutput>'#url.NumInspecao#','#url.coordenador#'</cfoutput>)"  href="#"
						class="botaoCad" style="position:relative;left:13px;top:20px"><img src="figuras/cadastro.png" width="25"  
						border="0" style="position:absolute;left:0px;top:5px">
						</img>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Clique para Confirmar o Cadastro desta Avaliação</a>
					</div>
			</div>

			<br>
			<cfif rsInspetoresCadastrados.recordCount neq 0>
				<div id="form_container" style="position:relative;top:-90px">
					<table width="720px" border="0" align="center">
						<tr bgcolor="write">
							<td colspan="8" align="center" class="titulos">
								<h1 style="font-size:14px">INSPETORES CADASTRADOS</h1>
							</td>
						</tr>

						<tr bgcolor="#6699CC" class="exibir" align="center" style="color:#fff">
							<td width="7%">
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
										<cfquery datasource="#dsn_inspecao#" name="nomeInspCad">
											SELECT Usu_Apelido, Dir_Sigla FROM usuarios 
										    INNER JOIN Diretoria ON  Dir_Codigo = Usu_DR
										    WHERE Usu_Matricula = convert(varchar,#IPT_MatricInspetor#)
										</cfquery>
										<cfif '#IPT_DtInicDesloc#' neq "1900/1/1">
											<cfset perDesloc='#DateFormat(IPT_DtInicDesloc,' dd/mm/yyyy')#' & ' a ' & '#DateFormat(IPT_DtFimDesloc,'
												dd/mm/yyyy')#'> 
										<cfelse>
										    <cfset perDesloc="não houve">
										</cfif>
										<cfset perInspec='#DateFormat(IPT_DtInicInsp,' dd/mm/yyyy')#' & ' a '
											& '#DateFormat(IPT_DtFimInsp,' dd/mm/yyyy')#'> 
										
										<tr valign="middle" bgcolor="#scor#" class="exibir">
											<td width="6%">
												<div align="center">#IPT_MatricInspetor#</div>
											</td>
											<td width="20%">
												<div align="left">#trim(nomeInspCad.Usu_Apelido)# (#trim(nomeInspCad.Dir_Sigla)#)</div>
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
					<div align="center">
						

							<a  href="javascript:history.back();" onClick="aguarde();" class="botaoCad" style="position:relative;"><img src="figuras/usuario.png" width="25"  border="0" 
								style="position:absolute;left:0px;top:5px"></img>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Voltar ao Cadastro de Inspetores</a>
					</div>
			</cfif>
			

    </div>
	
   


<!--- #######################Fim do Resumo da Finalização do Cadastramento##################- --->
    
 </cfif>

 

</cfif>

<cfif '#url.acao#' eq 'finalizado' >

	<div id="form_container" align="center">
		
		<h1 style="font-size:20px"><div align="center">CADASTRO DA AVALIAÇÃO FINALIZADO COM SUCESSO!</div></h1>
        <br>
		<div align="center"><img src="figuras/checkVerde.png" width="55"  border="0" style="position:relative;top:-8px"></img></div>
	<div>
</cfif>
</body>
<script src="public/jquery-3.7.1.min.js"></script>
<script>
	$(function(e){
		//alert('Dom foi iniciado!')
		let mod =''
		let dtdesloc = ''
		<cfoutput>
			mod = '#modalidade#'
			dtdesloc = '#dateformat(now(),"DD/MM/YYYY")#'
		</cfoutput>
		//alert('mod : '+mod)
		if(mod == 1){
			$('#dataInicioDesl').val(dtdesloc)
			$('#dataFimDesl').val(dtdesloc)
			$("#dataInicioDesl").prop('readonly', true)
			$("#dataFimDesl").prop('readonly', true)
			$('#horasPreInspecao').val(1)
			$("#horasPreInspecao").prop('readonly', true)
			$('#horasDeslocamento').val(1)
			$("#horasDeslocamento").prop('readonly', true)
		}
	})
</script>
</html>