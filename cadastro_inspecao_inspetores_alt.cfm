<cfprocessingdirective pageEncoding ="utf-8"/>
  <cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	<cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
  </cfif>    
  
  <cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_DR,Usu_GrupoAcesso, Usu_Matricula, Usu_Email, Usu_Apelido,Usu_Coordena from usuarios 
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
	ORDER BY INP_Coordenador
</cfquery>

<cfquery datasource="#dsn_inspecao#" name="rsInspAtual">
	SELECT * FROM Inspecao 
	WHERE INP_NumInspecao = '#url.NumInspecao#'
</cfquery>
<cfset nInsp = ''>
<cfset color =''>

<cfif isdefined('form.acao')>
<!---  --->
		<cfif '#form.acao#' eq 'altcadastro'>
			<!---  --->			
			<cfquery datasource="#dsn_inspecao#">
				UPDATE Unidades SET Und_NomeGerente = '#ucase(trim(form.responsavel))#' 
				WHERE Und_Codigo = '#url.Unid#'
			</cfquery>		
			<!---  --->	
			<cfquery datasource="#dsn_inspecao#" name="rsINSIPT">
				Select * FROM Inspetor_inspecao  WHERE IPT_NumInspecao = '#url.NumInspecao#'
			</cfquery>
			<cfquery datasource="#dsn_inspecao#">
					UPDATE Numera_Inspecao set NIP_DtIniPrev = CONVERT(DATETIME, '#form.dataInicioInsp#', 103)
					where NIP_NumInspecao = '#url.NumInspecao#'				
			</cfquery>
			<!---  --->			
			<cfoutput query="rsINSIPT">
				<cfquery datasource="#dsn_inspecao#">
				  UPDATE Inspetor_Inspecao SET 
				  IPT_DtInicInsp= CONVERT(DATETIME, '#form.dataInicioInsp#', 103), 
				  IPT_DtFimInsp= CONVERT(DATETIME, '#form.dataFimInsp#', 103), 
				  IPT_DtInicDesloc= CONVERT(DATETIME, '#form.dataInicioDesl#', 103), 
				  IPT_DtFimDesloc= CONVERT(DATETIME, '#form.dataFimDesl#', 103), 
				  IPT_NumHrsPreInsp= '#form.horasPreInspecao#', 
				  IPT_NumHrsdesloc= '#form.horasDeslocamento#', 
				  IPT_NumHrsInsp= '#form.horasInspecao#', 
				  IPT_DtUltAtu= CONVERT(char, getdate(), 120), 
				  IPT_UserName= '#qAcesso.Usu_Matricula#'
				  where IPT_NumInspecao = '#url.NumInspecao#' and IPT_MatricInspetor = '#rsINSIPT.IPT_MatricInspetor#'
				</cfquery>
			</cfoutput>
			
			<!---  --->			
		    <cfset tothrpreaval = form.horasPreInspecao * rsINSIPT.recordcount>
			<cfset tothraval = form.horasInspecao * rsINSIPT.recordcount>
			INP_HrsPreInspecao
			<cftransaction> 
			<cfif '#form.acao#' eq 'incInspetor'>			
				<cfloop list="#form.selInspetores#" index="i">  
					<cfquery datasource="#dsn_inspecao#" name="rsNumera_Inspecao_verif">
						Select IPT_NumInspecao FROM Inspetor_inspecao  WHERE IPT_NumInspecao = convert(varchar,'#url.NumInspecao#') and IPT_MatricInspetor = '#i#'
					</cfquery>
		
					<cfquery datasource="#dsn_inspecao#">
						insert into Inspetor_Inspecao (IPT_CodUnidade, IPT_NumInspecao, IPT_MatricInspetor, IPT_DtInicInsp, IPT_DtFimInsp, IPT_DtInicDesloc, IPT_DtFimDesloc, IPT_NumHrsPreInsp, IPT_NumHrsdesloc, IPT_NumHrsInsp, IPT_DtUltAtu, IPT_UserName)
						values ('#url.Unid#', '#url.NumInspecao#', '#i#', CONVERT(DATETIME, '#form.dataInicioInsp#', 103), CONVERT(DATETIME, '#form.dataFimInsp#', 103), CONVERT(DATETIME, '#form.dataInicioDesl#', 103), CONVERT(DATETIME, '#form.dataFimDesl#', 103), '#form.horasPreInspecao#', '#form.horasDeslocamento#', '#form.horasInspecao#', CONVERT(char, getdate(), 120), '#qAcesso.Usu_Matricula#')
					</cfquery>
					<cfset tothrpreaval = tothrpreaval + #form.horasPreInspecao#>
					<cfset tothraval = tothraval + #form.horasInspecao#>
				</cfloop>
			</cfif>				
			<!---  --->
			<cfquery datasource="#dsn_inspecao#">
				UPDATE inspecao SET INP_HrsPreInspecao = '#tothrpreaval#', 
			                    <cfif '#rsInspAtual.INP_Modalidade#' eq 0>
									INP_DtInicDeslocamento = CONVERT(DATETIME, '#form.dataInicioDesl#', 103),
									INP_DtFimDeslocamento =  CONVERT(DATETIME, '#form.dataFimDesl#', 103),
								</cfif>
								INP_HrsDeslocamento=  '#form.horasDeslocamento#',
								INP_DtInicInspecao=  CONVERT(DATETIME, '#form.dataInicioInsp#', 103),
								INP_DtFimInspecao=  CONVERT(DATETIME, '#form.dataFimInsp#', 103), 
								INP_DtEncerramento=  CONVERT(DATETIME, '#form.dataFimInsp#', 103),
								INP_Responsavel= '#ucase(trim(form.responsavel))#',
								INP_HrsInspecao= #tothraval#
				WHERE INP_NumInspecao = convert(varchar,'#url.NumInspecao#') 
			</cfquery>
			<cfquery datasource="#dsn_inspecao#" name="rsInspAtual">
				SELECT * FROM Inspecao 
				WHERE INP_NumInspecao = '#url.NumInspecao#'
			</cfquery>
			<cfquery datasource="#dsn_inspecao#" name="rsInspetoresCadastrados">
				SELECT Inspetor_Inspecao.*  
				FROM Inspetor_Inspecao INNER JOIN Funcionarios ON IPT_MatricInspetor = Fun_Matric
				WHERE IPT_NumInspecao = '#url.numInspecao#'
				ORDER BY Fun_Nome
			</cfquery>
			</cftransaction> 
	</cfif>
<!---  --->
	<cfif '#form.acao#' eq 'incInspetor'>
<!---  --->
		<cfif isDefined("form.selInspetores") and '#form.selInspetores#' neq "">
			<!---  --->			
			<cfquery datasource="#dsn_inspecao#">
				UPDATE Unidades SET Und_NomeGerente = '#ucase(trim(form.responsavel))#' 
				WHERE Und_Codigo = '#url.Unid#'
			</cfquery>		
			<!---  --->	
			<cfquery datasource="#dsn_inspecao#" name="rsINSIPT">
				Select * FROM Inspetor_inspecao  WHERE IPT_NumInspecao = '#url.NumInspecao#'
			</cfquery>
			<!---  --->	
			<cfquery datasource="#dsn_inspecao#">
					UPDATE Numera_Inspecao set NIP_DtIniPrev = CONVERT(DATETIME, '#form.dataInicioInsp#', 103)
					where NIP_NumInspecao = '#url.NumInspecao#'				
			</cfquery>
		
			<cfoutput query="rsINSIPT">
				<cfquery datasource="#dsn_inspecao#">
				  UPDATE Inspetor_Inspecao SET 
				  IPT_DtInicInsp= CONVERT(DATETIME, '#form.dataInicioInsp#', 103), 
				  IPT_DtFimInsp= CONVERT(DATETIME, '#form.dataFimInsp#', 103), 
				  IPT_DtInicDesloc= CONVERT(DATETIME, '#form.dataInicioDesl#', 103), 
				  IPT_DtFimDesloc= CONVERT(DATETIME, '#form.dataFimDesl#', 103), 
				  IPT_NumHrsPreInsp= '#form.horasPreInspecao#', 
				  IPT_NumHrsdesloc= '#form.horasDeslocamento#', 
				  IPT_NumHrsInsp= '#form.horasInspecao#', 
				  IPT_DtUltAtu= CONVERT(char, getdate(), 120), 
				  IPT_UserName= '#qAcesso.Usu_Matricula#'
				  where IPT_NumInspecao = '#url.NumInspecao#' and IPT_MatricInspetor = '#rsINSIPT.IPT_MatricInspetor#'
				</cfquery>
			</cfoutput>
			<cfset tothrpreaval = form.horasPreInspecao * rsINSIPT.recordcount>
		    <cfset tothraval = form.horasInspecao * rsINSIPT.recordcount>
			<cftransaction> 
			<cfif '#form.acao#' eq 'incInspetor'>			
				<cfloop list="#form.selInspetores#" index="i">  
					<cfquery datasource="#dsn_inspecao#" name="rsNumera_Inspecao_verif">
						Select IPT_NumInspecao FROM Inspetor_inspecao  WHERE IPT_NumInspecao = convert(varchar,'#url.NumInspecao#') and IPT_MatricInspetor = '#i#'
					</cfquery>
		
					<cfquery datasource="#dsn_inspecao#">
						insert into Inspetor_Inspecao (IPT_CodUnidade, IPT_NumInspecao, IPT_MatricInspetor, IPT_DtInicInsp, IPT_DtFimInsp, IPT_DtInicDesloc, IPT_DtFimDesloc, IPT_NumHrsPreInsp, IPT_NumHrsdesloc, IPT_NumHrsInsp, IPT_DtUltAtu, IPT_UserName)
						values ('#url.Unid#', '#url.NumInspecao#', '#i#', CONVERT(DATETIME, '#form.dataInicioInsp#', 103), CONVERT(DATETIME, '#form.dataFimInsp#', 103), CONVERT(DATETIME, '#form.dataInicioDesl#', 103), CONVERT(DATETIME, '#form.dataFimDesl#', 103), '#form.horasPreInspecao#', '#form.horasDeslocamento#', '#form.horasInspecao#', CONVERT(char, getdate(), 120), '#qAcesso.Usu_Matricula#')
					</cfquery>
					<cfset tothrpreaval = tothrpreaval + #form.horasPreInspecao#>
					<cfset tothraval = tothraval + #form.horasInspecao#>
				</cfloop>
			</cfif>				
			<!---  --->
			<cfquery datasource="#dsn_inspecao#">
				UPDATE inspecao SET INP_HrsPreInspecao = '#tothrpreaval#', 
			                    <cfif '#rsInspAtual.INP_Modalidade#' eq 0>
									INP_DtInicDeslocamento = CONVERT(DATETIME, '#form.dataInicioDesl#', 103),
									INP_DtFimDeslocamento =  CONVERT(DATETIME, '#form.dataFimDesl#', 103),
								</cfif>
								INP_HrsDeslocamento=  '#form.horasDeslocamento#',
								INP_DtInicInspecao=  CONVERT(DATETIME, '#form.dataInicioInsp#', 103),
								INP_DtFimInspecao=  CONVERT(DATETIME, '#form.dataFimInsp#', 103), 
								INP_DtEncerramento=  CONVERT(DATETIME, '#form.dataFimInsp#', 103),
								INP_Responsavel= '#ucase(trim(form.responsavel))#',
								INP_HrsInspecao= #tothraval#
				WHERE INP_NumInspecao = convert(varchar,'#url.NumInspecao#') 
			</cfquery>
			<!---  --->	
			<cfquery datasource="#dsn_inspecao#" name="rsInspAtual">
				SELECT * FROM Inspecao 
				WHERE INP_NumInspecao = '#url.NumInspecao#'
			</cfquery>
			<cfquery datasource="#dsn_inspecao#" name="rsInspetoresCadastrados">
				SELECT Inspetor_Inspecao.*  
				FROM Inspetor_Inspecao INNER JOIN Funcionarios ON IPT_MatricInspetor = Fun_Matric
				WHERE IPT_NumInspecao = '#url.numInspecao#'
				ORDER BY Fun_Nome
			</cfquery>		
			</cftransaction> 
    	</cfif>
<!---  --->
	</cfif>
</cfif>

<!--- Rotina para exclusão de inspetores --->
<cfif isdefined('url.acao')>
	<cfif '#url.acao#' eq 'excInspetor'>
		<cfif RIPMatricAvaliador eq 'N'>
				<cfquery datasource="#dsn_inspecao#">
					DELETE FROM Inspetor_Inspecao WHERE IPT_NumInspecao=trim(convert(varchar,'#url.numInspecao#')) and
					IPT_MatricInspetor=trim('#url.numMatricula#')
				</cfquery>
		
		<!---  --->
				<cfquery datasource="#dsn_inspecao#" name="rsINSIPT">
					Select * FROM Inspetor_inspecao  WHERE IPT_NumInspecao = '#url.NumInspecao#'
				</cfquery>
		
				<cfset tothraval = rsInspAtual.INP_HrsInspecao - rsINSIPT.IPT_NumHrsInsp>
				<cfset tothrpreaval = rsInspAtual.INP_HrsPreInspecao - rsINSIPT.IPT_NumHrsPreInsp>

				<cfquery datasource="#dsn_inspecao#">
					UPDATE inspecao SET INP_HrsInspecao= #tothraval#, INP_HrsPreInspecao=#tothrpreaval#
					WHERE INP_NumInspecao = trim(convert(varchar,'#url.numInspecao#')) 
				</cfquery>	
	    </cfif>				
		<cflocation url = "cadastro_inspecao_inspetores_alt.cfm?numInspecao=#url.NumInspecao#&Unid=#url.Unid#&coordenador=#url.coordenador#&dtInicDeslocamento=#url.dtInicDeslocamento#&dtFimDeslocamento=#url.dtFimDeslocamento#&dtInicInspecao=#url.dtInicInspecao#&dtFimInspecao=#url.dtFimInspecao#&RIPMatricAvaliador=#RIPMatricAvaliador###tabInsp" addToken = "no">
	</cfif>
<!---  --->	
	<cfif '#url.acao#' eq 'altInspetor'>
					<cfquery datasource="#dsn_inspecao#">
					UPDATE Inspecao SET INP_Coordenador = '#url.numMatricula#' 
					 WHERE INP_NumInspecao = trim('#url.numInspecao#')
					</cfquery>
					<cflocation url = "cadastro_inspecao_inspetores_alt.cfm?numInspecao=#url.NumInspecao#&Unid=#url.Unid#&coordenador=#url.numMatricula#&dtInicDeslocamento=#url.dtInicDeslocamento#&dtFimDeslocamento=#url.dtFimDeslocamento#&dtInicInspecao=#url.dtInicInspecao#&dtFimInspecao=#url.dtFimInspecao#&RIPMatricAvaliador=N##tabInsp" addToken = "no">
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

	
	<cfquery datasource="#dsn_inspecao#" name="rsInspetores">
		SELECT Usu_Matricula, Usu_Apelido, Dir_Sigla, CASE WHEN Usu_Matricula = '#url.coordenador#' THEN '0' ELSE '1' END AS ordem FROM Usuarios 
		INNER JOIN Diretoria ON  Dir_Codigo = Usu_DR
		INNER JOIN Funcionarios ON Fun_Matric = Usu_Matricula
		WHERE Usu_GrupoAcesso='INSPETORES' and Usu_DR in(#se#)  and Usu_Matricula not in(SELECT IPT_MatricInspetor FROM Inspetor_Inspecao WHERE IPT_NumInspecao = convert(varchar,'#url.numInspecao#'))
		ORDER BY ordem ASC, Dir_Sigla ASC, Usu_Apelido ASC
	</cfquery>

	<cfquery datasource="#dsn_inspecao#" name="rsInspetoresCadastrados">
		SELECT Inspetor_Inspecao.*  
		FROM Inspetor_Inspecao INNER JOIN Funcionarios ON IPT_MatricInspetor = Fun_Matric
		WHERE IPT_NumInspecao = '#url.numInspecao#'
		ORDER BY Fun_Nome
	</cfquery>
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
 

function verifQuantInspetores(){
<cfif isdefined('url.numInspecao')>
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
			resumoCadastro(<cfoutput>'#url.NumInspecao#','#url.coordenador#','url.Unid'</cfoutput>);
	</cfif>
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
		if ((tecla != 46) && ((tecla < 48) || (tecla > 57))) {
		event.returnValue = false;
	}
}
//================
function mensagem(x) {
	if (x == 'S') {
		alert('sr(a) Gestor(a) Exclusão não foi realizada com sucesso!. \n\nO inspetor possui item avaliado.'); 
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
function resumoCadastro(insp,coord,unid){
   var caminho = 'cadastro_inspecao_inspetores_alt.cfm?numInspecao=' + insp + '&Unid=' + unid + '&coordenador=' + coord + '&acao=resumo' +'#resumo';
	window.location.href(caminho);
}
//================
function valida_formCadNum(x) {
    var frm = document.forms[0];
	var mod ="";
	
	//alert(x);
    <cfoutput><cfif isDefined("url.numInspecao")>mod = '#rsInspecao.INP_Modalidade#'</cfif></cfoutput>;
	
    if (frm.selInspetores.value == '' && x == 'incInspetor') {
    	alert('Selecione, pelo menos, um inspetor na lista!');
    	frm.selInspetores.focus();
    	return false;
    }
	
	if (x == 'incInspetor') {frm.acao.value = 'incInspetor';}
	if (x == 'altcadastro') {frm.acao.value = 'altcadastro';}

	function gerarData(str) {
		var partes = str.split("/");
		return new Date(partes[2], partes[1] - 1, partes[0]);
    }
    var d = new Date();
	d.setHours(0,0,0,0);
	if(d > gerarData(frm.dataInicioDesl.value) && x != 'incInspetor' && x != 'altcadastro'){
		alert('A data de início do deslocamento não pode ser menor que a data de hoje.')
		frm.dataInicioDesl.focus();
		frm.dataInicioDesl.select();
		return false;
	}

	var dataInicioDesl =gerarData(frm.dataInicioDesl.value) ;
	var dataFimDesl =gerarData(frm.dataFimDesl.value) ;
	if(dataInicioDesl > dataFimDesl){
		alert('A data de fim do deslocamento não pode ser menor que a data de início do deslocamento.')
		frm.dataFimDesl.focus();
		frm.dataFimDesl.select();
		return false;
	}

    var dataInicioInsp =gerarData(frm.dataInicioInsp.value) ;
	var dataFimDesl =gerarData(frm.dataFimDesl.value) ;
	if(dataFimDesl < dataInicioInsp){
		alert('A data de início da verificação não pode ser maior que a data de fim do deslocamento.')
		frm.dataInicioInsp.focus();
		frm.dataInicioInsp.select();
		return false;
	}

	var dataInicioInsp =gerarData(frm.dataInicioInsp.value) ;
	var dataFimInsp =gerarData(frm.dataFimInsp.value) ;
	if(dataInicioInsp > dataFimInsp){
		alert('A data de fim da verificação não pode ser menor que a data de início da verificação.')
		frm.dataFimInsp.focus();
		frm.dataFimInsp.select();
		return false;
	}


	var dataFimDesl =gerarData(frm.dataFimDesl.value) ;
	var dataFimInsp =gerarData(frm.dataFimInsp.value) ;
	if(dataFimInsp > dataFimDesl){
		alert('A data de fim da verificação não pode ser maior que a data de fim do deslocamento.')
		frm.dataFimInsp.focus();
		frm.dataFimInsp.select();
		return false;
	}

	var dataInicioInsp =gerarData(frm.dataInicioInsp.value) ;
	var dataInicioDesl =gerarData(frm.dataInicioDesl.value) ;
	if(dataInicioInsp < dataInicioDesl){
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
	
	var gestorunid = frm.responsavel.value;
	if (gestorunid.length == 0) {
    	alert('Informe a nome do Gestor da Unidade!');
    	frm.responsavel.focus();
		frm.responsavel.select();
    	return false;
    }	

//-----------------------------------------------------------------------

	if(window.confirm("Confirma o nome do Gestor da Unidade?")){
		aguarde();
	}else{
		return false;
	}

//-----------------------------------------------------------------------
if (x == 'incInspetor') {
	if(window.confirm("Confirma a inclusão de novo(s) inspetor(es)?")){
		aguarde();
	}else{
		return false;
	}
}	
//-----------------------------------------------------------------------
if (x == 'altcadastro') {
	if(window.confirm("Confirma alteração no Cadastro de Avaliação?")){
		aguarde();
	}else{
		return false;
	}
}	
//------------------------------------------------------------------------    
 }

	</script>

</head>
<body id="main_body" onLoad="mensagem('<cfoutput>#RIPMatricAvaliador#</cfoutput>')">
<div id="aguarde" name="aguarde" align="center"  style="width:100%;height:100%;top:0px;left:0px; background:transparent;filter:progid:DXImageTransform.Microsoft.gradient(startColorstr=#7F86b2ff,endColorstr=#7F86b2ff);z-index:10000;visibility:hidden;position:absolute;" >		
				<img i="imagAguarde" name="imgAguarde"" src="figuras/aguarde.png" width="100px"  border="0" style="position:relative;top:200px"></img>
		    </div>
	<!--- <cfinclude template="cabecalho.cfm"> --->
	<div align="left" style="margin:10px">
		
	<a href="itens_inspetores_avaliacao.cfm?numInspecao=<cfoutput>#url.numInspecao#</cfoutput>&Unid=<cfoutput>#url.Unid#</cfoutput>" onClick="aguarde();" class="botaoCad" style="position:relative;left:13px;"><img src="figuras/voltar.png" width="25"  border="0" style="position:absolute;left:5px;top:3px"></img>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Voltar à Página Anterior</a>
	</div>

	

	
	<cfif isdefined('url.acao')>
		<cfif '#url.acao#' neq 'resumo' and '#url.acao#' neq 'finalizado'>

	<cfif isDefined("url.numInspecao")>
		
		<br>
	
	   	<div id="form_container" style="position:relative;">
			
			<a id="formCad"></a>
			
			<h1 style="font-size:20px">
				<img src="figuras/usuario.png" width="55"  border="0" style="position:absolute;"></img>
				<div align="center">Cadastro de Inspetores - Avaliação n° <cfoutput><strong>#url.numInspecao#</strong></cfoutput>
					<br>
					
					<cfquery datasource="#dsn_inspecao#" name="rsUnidadeSelecionada">
						SELECT Und_Codigo, Und_Descricao,Dir_Sigla,Und_NomeGerente FROM Unidades 
						INNER JOIN Diretoria ON  Dir_Codigo = Und_CodDiretoria
						WHERE Und_Status='A' and Und_Codigo	='#rsInspAtual.INP_Unidade#'
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
								#trim(rsUnidadeSelecionada.Dir_Sigla)# - #trim(rsUnidadeSelecionada.Und_Descricao)# (#trim(rsUnidadeSelecionada.Und_Codigo)#) - Mod.: <cfif '#rsInspecao.INP_Modalidade#' eq 0>
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
				onSubmit="return valida_formCadNum('incCadstro')" enctype="multipart/form-data" method="post"
				action="cadastro_inspecao_inspetores_alt.cfm?<cfoutput>
															numInspecao=#url.NumInspecao#
															&Unid=#url.Unid#
															&coordenador=#url.coordenador#
															&dtInicDeslocamento=#url.dtInicDeslocamento#
															&dtFimDeslocamento=#url.dtFimDeslocamento#
															&dtInicInspecao=#url.dtInicInspecao#
															&dtFimInspecao=#url.dtFimInspecao#
															&RIPMatricAvaliador=N
														</cfoutput>
														#tabInsp">

				<cfif isDefined("url.numInspecao")>
					<cfquery datasource="#dsn_inspecao#" name="rsInspecao">
							SELECT * FROM Inspecao WHERE INP_NumInspecao = '#url.numInspecao#' and INP_Situacao='NA'
					</cfquery>
				</cfif>	

				<div align:"center" style="position:relative;left:88px">	
					<tr>
						<td>
							<label for="selInspetores" style="color:grey">Selecione um ou mais Inspetores:</label>
							<br>
							<select multiple name="selInspetores" id="selInspetores" class="form" style="width:500px;height:80px">
								<cfoutput query="rsInspetores">
									<option  <cfif  '#trim(Usu_Matricula)#' eq '#url.coordenador#' >selected</cfif> value="#trim(Usu_Matricula)#"><cfif  '#trim(Usu_Matricula)#' eq '#url.coordenador#' >Coord.: </cfif>#trim(Dir_Sigla)# - #trim(Usu_Apelido)#</option>
								</cfoutput>
							</select><br><span style="font-size:11px;color:cadetblue;position:absolute;top:88px">Mantenha pressionada a tecla "CTRL" para selecionar mais de um inspetor.</span>
						</td>
						</tr>
						<br>
				<tr><td>


 				<div align="left">

					<a name="btCadastrar" onClick="return valida_formCadNum('incInspetor')" id="btCadastrar" href="javascript:formCadNum.submit()"
									class="botaoCad" style="position:relative;left:13px;"><img src="figuras/usuario.png" width="25"  
									border="0" style="position:absolute;left:0px;top:5px">
								</img>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Incluir Novo(s) Inspetor(es)</a>								
	
				</div> 
			
<!---  --->

<br>
<!---  --->

			</td>
					</tr>
				</div>	

					<br>
<tr><td></td></tr>				
				<div style="WIDTH: 202px; RIGHT:18px;POSITION: absolute; PADDING: 5px;TOP: 257px;BACKGROUND-COLOR:#fff;border:1px solid #e0dddd">
					<span style="color:gray;font-size:14px;position:absolute;top:-19px;left:0px">Carga Horária (por inspetor):</span>
					<tr>
					<td>
						<cfquery datasource="#dsn_inspecao#" name="rsInspCadastrados">
							SELECT IPT_MatricInspetor, IPT_NumHrsPreInsp FROM Inspetor_Inspecao WHERE IPT_NumInspecao = '#url.numInspecao#'
						</cfquery>
						<label for="horasPreInspecao" style="color:gray">Horas Pré-Avaliação:</label>
						<input id="horasPreInspecao" name="horasPreInspecao" type="text" 
						    value="<cfoutput><cfif isDefined("url.numInspecao") and '#rsInspAtual.INP_Modalidade#' eq '0'>#rsInspCadastrados.IPT_NumHrsPreInsp#<cfelse>0</cfif></cfoutput>" 
							onKeyPress="numericos()" maxlength="2" 	style="width:20px;text-align:center;margin-left:3px;border:1px solid #e0dddd"
							
								<cfif isDefined("url.numInspecao") and '#rsInspAtual.INP_Modalidade#' eq '1'>
									style="background:#eef1f3;text-align:center;"
									
								</cfif>	
								<cfif isDefined("url.numInspecao") and '#rsInspCadastrados.recordcount#' gte '1'>
									style="background:#eef1f3;text-align:center;"
									
								</cfif>
						

					</td>
					<br>
					<td>
						<label for="horasDeslocamento" style="color:gray">Horas Deslocamento:</label>
						<input id="horasDeslocamento" name="horasDeslocamento" type="text" 
						value="<cfoutput><cfif isDefined("url.numInspecao")>#rsInspetoresCadastrados.IPT_NumHrsDesloc#</cfif></cfoutput>"
						style="width:20px;text-align:center;margin-left:0px;border:1px solid #e0dddd" onKeyPress="numericos()" maxlength="2" 
						<cfif isDefined("url.numInspecao") and '#rsInspCadastrados.recordcount#' gte '1'>
							style="background:#eef1f3;"
							
						</cfif>
						/>
					</td>
					<br>
					<td>
						<label for="horasInspecao" style="color:gray">Horas Avaliação:
							&nbsp;&nbsp;&nbsp;&nbsp;</label>
						<input id="horasInspecao" name="horasInspecao" type="text" 
						value="<cfoutput><cfif isDefined("url.numInspecao")>#rsInspetoresCadastrados.IPT_NumHrsInsp#</cfif></cfoutput>" style="border:1px solid #e0dddd;width:20px;text-align:center;margin-left:7px"
							onKeyPress="numericos()" maxlength="2" 
							<cfif isDefined("url.numInspecao") and '#rsInspCadastrados.recordcount#' gte '1'>
								style="background:#eef1f3;"
								
							</cfif>/>
					</td>
				  </tr>
				</div>
				<br>
				<div style="background:#fff;padding:5px;padding-top:6px;position:relative;top:-15px;height:30px;width:442px;border:1px solid #e0dddd">
				<span style="color:gray;font-size:14px;position:absolute;top:-19px;left:0px">Gestor da Unidade.:</span>
				<tr>
					<td>
						<input id="responsavel" name="responsavel" 
						 type="text" value="<cfoutput>#rsUnidadeSelecionada.Und_NomeGerente#</cfoutput>" style="width:60%;text-align:left" style="background:#eef1f3;" size="40" maxlength="30" />
					
					</td>
				</tr>	 
				</div>
				
<!---  --->
<!---  --->				

				<br>
				<div style="background:#fff;padding:5px;padding-top:6px;position:relative;top:-15px;height:77px;width:442px;border:1px solid #e0dddd">
				<span style="color:gray;font-size:14px;position:absolute;top:-19px;left:0px">Datas.:</span>
				<tr>
					<td>
						<label for="dataInicioDesl" style="color:gray">Início Desloc.:&nbsp;&nbsp;</label>
						<cfset dataInicioDesl = DateFormat(rsInspAtual.INP_DtInicDeslocamento,"dd/mm/yyyy")>
						<input id="dataInicioDesl" name="dataInicioDesl" type="text" value="<cfoutput>#dataInicioDesl#</cfoutput>" style="width:82px;border:1px solid #e0dddd"
							onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" size="14" maxlength="10" style="background:#eef1f3;" />
					</td>

					<td colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp</td>
					<td>
						<label for="dataFimDesl" style="color:gray">Fim Desloc.:&nbsp;&nbsp;&nbsp;</label>
						<cfset dataFimDesl = DateFormat(rsInspAtual.INP_DtFimDeslocamento,"dd/mm/yyyy")>
						<input id="dataFimDesl" name="dataFimDesl" type="text" value="<cfoutput>#dataFimDesl#</cfoutput>" style="width:82px;border:1px solid #e0dddd"
							onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" size="14" maxlength="10" style="background:#eef1f3;" />
					</td>

					
				</tr>

				<br><br>
				<tr>
					<td>
						<label for="dataInicioInsp" style="color:gray">Início Aval.:&nbsp;&nbsp;&nbsp;&nbsp;</label>
						<cfset dataInicioInsp = DateFormat(rsInspAtual.INP_DtInicInspecao,"dd/mm/yyyy")>
						<input id="dataInicioInsp" name="dataInicioInsp" type="text" value="<cfoutput>#dataInicioInsp#</cfoutput>" style="width:82px;border:1px solid #e0dddd;margin-left:5px"
							onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" size="14" maxlength="10" style="background:#eef1f3;" />
					</td>

					<td colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>

					<td>
						<label for="dataFimInsp" style="color:gray">Fim Aval.:&nbsp;&nbsp;&nbsp;</label>
						<cfset dataFimInsp = DateFormat(rsInspAtual.INP_DtFimInspecao,"dd/mm/yyyy")>
						<input id="dataFimInsp" name="dataFimInsp" type="text" value="<cfoutput>#dataFimInsp#</cfoutput>" style="width:82px;border:1px solid #e0dddd;margin-left:13px"
							onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" size="14" maxlength="10" style="background:#eef1f3;" />
					</td>

					
				</tr>
				</div>	
<!---  --->	
<label for="tothrpre" style="color:gray">Total Geral (Horas em Pré-Avaliação).:&nbsp;&nbsp;<cfoutput>#rsInspAtual.INP_HrsPreInspecao#</cfoutput></label><br>
<label for="tothraval" style="color:gray">Total Geral (Horas em Avaliação).:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cfoutput>#rsInspAtual.INP_HrsInspecao#</cfoutput></label>
<!---  --->					
		<input type="hidden" name="acao" id="acao" value="">
				
			</form>
			
		</div>
	
		<cfif rsInspetoresCadastrados.recordCount neq 0>
			
			<div id="form_container" style="position:relative;top:-25px">
				<table width="720px" border="0" align="center">
					
					
					
					<tr bgcolor="write">
						<td colspan="10" align="center" class="titulos">
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
						<td width="3%">
							<div align="center">Coor dena</div>
						</td>
						<td width="3%">
							<div align="center">Alter. Coorde nador</div>
						</td>						
						<td width="5%">
							<div align="center">Excluir</div>
						</td>

					</tr>
					<tr>

						<cfset scor='white'>
						    <cfset qtdinspetores = rsInspetoresCadastrados.recordcount> 
							<cfoutput query="rsInspetoresCadastrados">
								<form action="" method="POST" name="formexc">
									<cfquery datasource="#dsn_inspecao#" name="nomeInspCad">
										SELECT Usu_Apelido, Dir_Sigla FROM usuarios 
										INNER JOIN Diretoria ON  Dir_Codigo = Usu_DR
										WHERE Usu_Matricula =
										convert(varchar,#IPT_MatricInspetor#)
									</cfquery>
								<cfif isdefined('form.dataInicioDesl') and '#form.dataInicioDesl#' neq "">	
									<cfset perDesloc='#DateFormat(IPT_DtInicDesloc,' dd/mm/yyyy')#' & ' a '
										& '#DateFormat(IPT_DtFimDesloc,' dd/mm/yyyy')#'> 
								<cfelse>
									<cfset perDesloc="não houve">
                                 </cfif>
								<cfset auxcoord = 'Não'>
								<cfif url.Coordenador eq IPT_MatricInspetor>
									<cfset auxcoord = 'Sim'>
								</cfif>
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
										<td width="3%">
											<div align="center">#auxcoord#</div>
										</td>
										
										<td width="3%">
										 <cfif auxcoord neq 'Sim'>
											<div align="center"><a
													onclick="return confirm('Confirma alterar este Inspetor para ser coordenador desta Avaliação? \n#trim(nomeInspCad.Usu_Apelido)#')"
													href="cadastro_inspecao_inspetores_alt.cfm?numInspecao=#IPT_NumInspecao#&Unid=#url.Unid#&numMatricula=#IPT_MatricInspetor#&coordenador=#url.Coordenador#&dtInicDeslocamento=#url.dtInicDeslocamento#&dtFimDeslocamento=#url.dtFimDeslocamento#&dtInicInspecao=#url.dtInicInspecao#&dtFimInspecao=#url.dtFimInspecao#&RIPMatricAvaliador=N&acao=altInspetor"><img
														src="icones/monitora.png" width="20" height="20" border="0" alt="Clique para mudar de Coordenador desta Avaliação"></img></a>
											</div>
										</cfif>
										</td>	
										<!---  --->	
										<cfset RIP_MatricAvaliador='N'>
										<cfquery datasource="#dsn_inspecao#" name="rsResultInspec">
											SELECT RIP_MatricAvaliador
											FROM Resultado_Inspecao
											WHERE RIP_NumInspecao= '#IPT_NumInspecao#' and RIP_Unidade= '#url.Unid#' and RIP_MatricAvaliador = '#IPT_MatricInspetor#'
										</cfquery>
										<cfif rsResultInspec.recordcount gt 0>
											<cfset RIP_MatricAvaliador='S'>
										</cfif>
										<!---  --->																		
										<td width="5%">
										<cfif auxcoord neq 'Sim' and qtdinspetores gt 2>	
											<div align="center"><a
													onclick="return confirm('Confirma a exclusão deste Inspetor como participante desta Inspeção? \n#trim(nomeInspCad.Usu_Apelido)#')"
													href="cadastro_inspecao_inspetores_alt.cfm?numInspecao=#IPT_NumInspecao#&Unid=#url.Unid#&numMatricula=#IPT_MatricInspetor#&coordenador=#url.Coordenador#&dtInicDeslocamento=#url.dtInicDeslocamento#&dtFimDeslocamento=#url.dtFimDeslocamento#&dtInicInspecao=#url.dtInicInspecao#&dtFimInspecao=#url.dtFimInspecao#&RIPMatricAvaliador=#RIP_MatricAvaliador#&acao=excInspetor"><img
														src="icones/lixeiraRosa.png" width="20" height="20" border="0"></img></a>
											</div>
										</cfif>
										</td>
					</tr>
                    	<input type="hidden" name="acao" id="acao" value="">
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
<br>
				<div align="center">
						<a name="btCadastrar" onClick="return valida_formCadNum('altcadastro')" id="btCadastrar" href="javascript:formCadNum.submit()"
									class="botaoCad" style="position:relative;left:13px;"><img src="figuras/cadastro.png" width="25"  
									border="0" style="position:absolute;left:0px;top:5px">
								</img>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Alterar Cadastro da Avaliação</a>
				</div>
		</cfif>
				</div>
				</div>
				
				<a id="tabInsp"></a>

  </cfif>

</cfif>

</cfif>

</body>
</html>





	

