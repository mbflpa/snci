	 <!---
	<cfquery name="rsgilvan" datasource="DBSNCI">
       select Usu_Apelido, Usu_Matricula from Usuarios order by Usu_Apelido
   </cfquery>

  <cfoutput query="rsgilvan">
   <cfset maiusculas = Ucase(#Usu_Apelido#)>
   apelido : #Usu_Apelido# -  apelido maiuscula : #maiusculas# - matricula : #Usu_Matricula#<br>
   <cfquery datasource="DBSNCI">
	 UPDATE Usuarios SET Usu_Apelido = '#maiusculas#' WHERE Usu_Matricula = '#Usu_Matricula#'
   </cfquery>  
  </cfoutput> 
  --->

<cfoutput>
  <cfset seprinc = #form.ssuper#>
  <cfset sesubor = #form.ssuper#>
  <cfset slabel = #form.slabel#>
</cfoutput>
	<html>
	<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<title>Sistema Nacional de Controle Interno</title>
	<link href="../../estilo.css" rel="stylesheet" type="text/css">
	<link href="css.css" rel="stylesheet" type="text/css">

	</head>

	<script language="JavaScript" src="../../mm_menu.js"></script>
	<body onLoad="carregar()"; onsubmit="mensagem()">
<script type="text/javascript">
// função que transmite as rotinas de alt, exc, etc...
function incluir(a,b,c,d,e,f,g,h,i,j){
	//          a            b                 c             d                  e                f                g          h               
	//dominio.value,matr_usu.value,apelido_usu.value,area_usu.value,lotacao_uni.value,lotacao_reop.value,lotacao_usu.value,'inc')
    c = c.toUpperCase();
	//alert(a + ' ' + b + ' ' + c + ' ' + d + ' ' + e + ' ' + f + ' ' + g + ' ' + h);
					
	if (a == "---" || b == "" || c == "" || d == "---") {
	   alert("Um ou mais campo(s) por selecionar desta ação.");
	   return false;
	}
    if (a == "CORREIOSNET" && b.length != 11) {
	   alert("Favor informar a Matrícula com 8 dígitos.");
	   return false;
	}
	if (a == "EXTRANET" && b.length != 14) {
	   alert("Favor informar o CPF com 11 dígitos.");
	   return false;
	}	
	if (e == "---" && f == "---" && g == "---" && h == "---" && i == "---") {
	   alert("Favor selecionar uma lotação desta ação!");
	   return false;
	}
 //	if (confirm ("Deseja continuar?"))
//	   {
	   document.formx.sdominio.value=a;
	   document.formx.smatr_usu.value=b;
	   document.formx.sapelido_usu.value=c;
	   document.formx.sarea_usu.value=d;
	   document.formx.slotacao_uni.value=e;
	   document.formx.slotacao_reop.value=f;
	   document.formx.slotacao_usu.value=g;
	   document.formx.sdepartamento.value=h;
	   document.formx.ssuperintendencia.value=i;
	   document.formx.sacao.value=j;
       document.formx.submit(); 
//		}
//	else
//	   {
//	   return false;
//	   }
}
//=============================

function excluir(a,b,c){
  //         a           b       c
  //    area.value,login.value,'exc'

 	if (confirm ("Deseja Excluir?"))
	   {
  		document.formx.sarea_ga.value=a;
        document.formx.slogin.value=b;
		document.formx.sacao.value=c;
		document.formx.submit(); 
		}
	else
	   {
	   return false;
	   }
}
//==============================
	<!--//Validação de campos vazios em formulário -->
	function voltar(){
       document.formvolta.submit();
    }
//==========================================	
	function Mascara_Matricula(Matricula)
	{
		switch (Matricula.value.length)
		{
			case 1:
				Matricula.value += ".";
				break;
			case 5:
				Matricula.value += ".";
				break;
			case 9:
				Matricula.value += "-";
				break;
		}
	}
//=============================================
	function Mascara_cpf(cpf)
	{
		switch (cpf.value.length)
		{
			case 3:
				cpf.value += ".";
				break;
			case 7:
				cpf.value += ".";
				break;
			case 11:
				cpf.value += "-";
				break;
		}
	}
	//=================================
	function validacao()
	{
		var ctrl=window.event.ctrlKey;

		var tecla=window.event.keyCode;
/*
		if (ctrl && tecla==67) {
			alert("CTRL+C"); 
			event.keyCode=0; 
			event.returnValue=false;
		}
*/
		if (ctrl && tecla==86) {
			alert("CTRL+V não permitido!"); 
			event.keyCode=0; 
			event.returnValue=false;
		}
	}
//permite digitaçao apenas de valores numéricos
function numericos() {
var tecla = window.event.keyCode;
//permite digitação das teclas numéricas (48 a 57, 96 a 105), Delete e Backspace (8 e 46), TAB (9) e ESC (27)
//if ((tecla != 8) && (tecla != 9) && (tecla != 27) && (tecla != 46)) {
	
	if ((tecla != 46) && ((tecla < 48) || (tecla > 57))) {
		//alert(tecla);
	//  if () {
		event.returnValue = false;
	 // }
	}
//}
}
//============================================	
	function verificaForm(form){
	 if(document.form.apelido_usu.value == ""){
	 alert("Preencha os campos Matricula e Nome.")
	 return false
	  }
	}
//==========================================	
	// identificar e setar select option

// percorre o slect item a item e identifica o value e o label
function buscaopt(a) {
   var opt_sn = 'N';
   var cmbseunid = document.getElementById("lotacao_usu");
   for (i = 1; i < cmbseunid.length; i++) {
        //   alert(cmbseunid.options[i].value);
       //    alert(cmbseunid.options[i].text);
      //     alert(cmbseunid.options[i].text.substring(3,cmbseunid.options[i].text.length) + '  ' + a);
      //     alert(cmbseunid.options[i].text.length);
// comparando o valor do label
           if (cmbseunid.options[i].text.substring(cmbseunid.options[i].text.indexOf("/") + 1,cmbseunid.options[i].text.length) ==  a){
          //     alert(i);
		       opt_sn = 'S'
               cmbseunid.selectedIndex = i;
                cmbseunid.disabled=true;
                i = cmbseunid.length;
           }
    }
	if (opt_sn == "N"){
           //    alert(i);
               cmbseunid.selectedIndex = 0;
               cmbseunid.disabled=true;

           }
}
//===================================
//	========== Início desabilitar campos ========
	function desabilita_campos(){
		var frm = document.forms[0];
		frm.lotacao_uni.selectedIndex = 0;
		frm.lotacao_uni.disabled=true;

		frm.lotacao_reop.selectedIndex = 0;
		frm.lotacao_reop.disabled=true;
		
		frm.lotacao_usu.selectedIndex = 0;
		frm.lotacao_usu.disabled=true;
		
		frm.departamento.selectedIndex = 0;
		frm.departamento.disabled=true;
		
		frm.superintendencia.selectedIndex = 0;
		frm.superintendencia.disabled=true;
		
		if(frm.area_usu.value=='UNIDADES'){
				frm.lotacao_uni.disabled=false;
				frm.lotacao_uni.selectedIndex = 0;
				frm.lotacao_uni.focus();
		  }
		 if(frm.area_usu.value=='ORGAOSUBORDINADOR'){
				frm.lotacao_reop.disabled=false;
				frm.lotacao_reop.selectedIndex = 0;
				frm.lotacao_reop.focus();
		  }
		/* if(frm.area_usu.value=='INSPETORES'){
				frm.lotacao_usu.disabled=false;			
				frm.lotacao_usu.selectedIndex = 0;
				buscaopt('DCINT/GCOP/CVCO/SCOI');
				frm.lotacao_usu.focus();
		  }
		 if(frm.area_usu.value=='GESTORES'){
				frm.lotacao_usu.disabled=false;
				frm.lotacao_usu.selectedIndex = 0;
				buscaopt('DCINT/GCOP/CVCO/SCOI');
				frm.lotacao_usu.focus();
		  }
		 */
		 if(frm.area_usu.value=='DESENVOLVEDORES' || frm.area_usu.value=='GESTORES' || frm.area_usu.value=='INSPETORES' || frm.area_usu.value=='GESTORMASTER'){
				frm.lotacao_usu.disabled=false;
				frm.lotacao_usu.selectedIndex = 0;
				buscaopt('CVCO');
				frm.lotacao_usu.focus();
		  }
		  if(frm.area_usu.value=='GERENTES'){
				frm.lotacao_usu.disabled=false;
				frm.lotacao_usu.selectedIndex = 0;
				frm.lotacao_usu.focus();
		  }
		  if(frm.area_usu.value=='SUBORDINADORREGIONAL'){
				frm.lotacao_usu.disabled=false;
				frm.lotacao_usu.selectedIndex = 0;
				frm.lotacao_usu.focus();
		  }
		  if(frm.area_usu.value=='DEPARTAMENTO'){
				frm.departamento.disabled=false;
				frm.departamento.selectedIndex = 0;
				frm.departamento.focus();
		  }
		   if(frm.area_usu.value=='SUPERINTENDENTE'){
				frm.superintendencia.disabled=false;
				frm.superintendencia.selectedIndex = 0;
				frm.superintendencia.focus();
		  }
	}
//	========== final desabilitar campos ========


//	========== inicio exibirdominio ========
	function exibirdominio(){
	  var frm = document.forms[0];
	  if(frm.dominio.value=='CORREIOSNET'){
	    frm.matr_usu.style.visibility = 'visible';
	    frm.conta.style.visibility = 'hidden';
	    frm.matr_usu.focus();
	  }else{
	  	frm.conta.style.visibility = 'visible';
	  	frm.matr_usu.style.visibility = 'hidden';
	  	frm.conta.focus();
	  }
	}
//	========== final exibirdominio ========

//	========== inicio carregar ========
//  E exectado no evento <body onLoad="carregar()"> desta página
	function carregar(){
	  var frm = document.forms[0];
	  frm.matr_usu.style.visibility = 'visible';
	  frm.conta.style.visibility = 'hidden';
	  frm.lotacao_uni.disabled=true;
	  frm.lotacao_usu.disabled=true;
	  frm.lotacao_reop.disabled=true;
	  frm.lotacao_se.disabled=true;
	  frm.lotacao_cs.disabled=true;
	}
//	========== final carregar ========
</script>
	
    <cfinvoke component="SNCI.cfc.rotinas_permissoes" method="rsqArea" returnvariable="request.qArea">
	</cfinvoke>
<!--- 	<cfquery name="qArea" datasource="#dsn_inspecao#">
	 SELECT TOP 1 '---' as Usu_GrupoAcesso FROM Usuarios
	 UNION
	 SELECT DISTINCT RTRIM(LTRIM(Usu_GrupoAcesso)) as Usu_GrupoAcesso FROM Usuarios
	 ORDER BY Usu_GrupoAcesso ASC
	</cfquery> --->

    <cfinvoke component="SNCI.cfc.rotinas_permissoes" method="rsArea1" returnvariable="request.Area1">
			 <cfinvokeargument name="sSEprinci" value="#seprinc#">
			 <cfinvokeargument name="sSEsubord" value="#sesubor#">
	</cfinvoke>
    
	<cfinvoke component="SNCI.cfc.rotinas_permissoes" method="rsqArea2" returnvariable="request.qArea2">
				 <cfinvokeargument name="sSEprinci" value="#seprinc#">
				 <cfinvokeargument name="sSEsubord" value="#sesubor#">
    </cfinvoke>
	<cfinvoke component="SNCI.cfc.rotinas_permissoes" method="rsqSE" returnvariable="request.qSE">
			 <cfinvokeargument name="sSEprinci" value="#seprinc#">
			 <cfinvokeargument name="sSEsubord" value="#sesubor#">
    </cfinvoke>

	<cfinvoke component="SNCI.cfc.rotinas_permissoes" method="rsqCS" returnvariable="request.qCS">
	</cfinvoke>

	<cfinvoke component="SNCI.cfc.rotinas_permissoes" method="rsqReop" returnvariable="request.qReop">
			 <cfinvokeargument name="sSEprinci" value="#seprinc#">
			 <cfinvokeargument name="sSEsubord" value="#sesubor#">
	</cfinvoke>

	<cfinvoke component="SNCI.cfc.rotinas_permissoes" method="rsqUnidade" returnvariable="request.qUnidade">
			 <cfinvokeargument name="sSEprinci" value="#seprinc#">
			 <cfinvokeargument name="sSEsubord" value="#sesubor#">
	</cfinvoke>
      <form action="" method="POST" name="forminc">
	    <span class="exibir"><strong>
	    </strong></span>
	    <table width="85%" border="0" align="center">
	      <tr valign="baseline">
	        <td colspan="6" class="exibir"><div align="center"><span class="titulo1"><strong>Permiss&Otilde;es</strong></span></div></td>
	      </tr>
 
	     <tr valign="baseline">
		      <td colspan="6"><span class="titulos">Superintendência:</span></td>
	  </tr>
			 <tr valign="baseline">
		     <td colspan="6"> 
			   <cfoutput>
			    <select name="dr" id="dr" class="form" disabled>
		          <option selected="selected" value="#ssuper#">#slabel#</option>
		        </select>
	           </cfoutput>
			 </td>
			 </tr>
        <tr valign="baseline">
	      <td colspan="6"><span class="titulos">Domínio:</span></td>
		</tr>

        <tr valign="baseline">
	     <td colspan="6"><select name="dominio" id="dominio" class="form"" onChange="(matr_usu.value='')">
	          <option selected="selected" value="---">---</option>
	          <option value="CORREIOSNET">CORREIOSNET</option>
			  <option value="EXTRANET">EXTRANET</option>
	        </select></td>
	    </tr>

		 <tr valign="baseline">
	      <td colspan="6"><span class="titulos">Matr&iacute;cula/CPF:</span></td>
	    </tr>
        <tr valign="baseline">
	      <td colspan="6"><input type="text" name="matr_usu" id="matr_usu" class="form" maxlength="14"  onKeyDown="validacao();" onKeyPress="if(dominio.value == 'CORREIOSNET'){Mascara_Matricula(this)}else if (dominio.value == 'EXTRANET'){Mascara_cpf(this)} else {dominio.focus()}; numericos()">
		  <!--- <br><input type="text" name="matr_usu" id="matr_usu" class="form" onKeyPress="Mascara_cpf(this)" maxlength="14"></td> --->
	    </tr>
	    <tr valign="baseline">
	      <td colspan="6"><span class="titulos">Nome:</span></td>
	    </tr>
		
	    <tr valign="baseline">
	      <td colspan="6"><input name="apelido_usu" type="text" class="form" id="apelido_usu" size="52" maxlength="50" onKeyDown="validacao();" onKeyPress="if(dominio.value == '---'){dominio.focus()}"> <span class="titulos">Ex: EDIMIR BARBOSA MARIZ</span></td>
	    </tr>

<!--- Áreas para seleção de permissão --->

	<!--- Consulta Permissões nas páginas --->
	<cfquery name="qPermissoes" datasource="#dsn_inspecao#">
		SELECT distinct Ars_sigla, Ars_Descricao, Usu_GrupoAcesso, Usu_Lotacao, Usu_Matricula, Usu_Login, Usu_Apelido, Usu_LotacaoNome
	    FROM Usuarios LEFT OUTER JOIN Areas ON Usuarios.Usu_Lotacao = Areas.Ars_Codigo
		WHERE Usuarios.Usu_DR = '#seprinc#'
	    ORDER BY Usu_Apelido, Usu_GrupoAcesso, Usu_Lotacao, Usu_Matricula
	</cfquery>
	<!--- ÁREA DE CONTEÚDO --->
	

        <tr valign="baseline">
	      <td colspan="6"><span class="titulos">Grupo de Acesso:</span></td>
		</tr>
		<tr valign="baseline"> 
	      <td colspan="6">
		   <select name="area_usu" id="area_usu" class="form" onchange="desabilita_campos(this.value)">
	          <cfoutput query="request.qArea"> 
	            <option value="#UCase(Usu_GrupoAcesso)#">#UCase(Usu_GrupoAcesso)#</option>
	          </cfoutput>
	        </select>
	      </td>
	    </tr>
	    <tr valign="baseline">
	      <td colspan="6">&nbsp;</td>
	    </tr>
	    <tr valign="baseline">
	      <td height="19" colspan="6"><span class="titulos">Lota&ccedil;&atilde;o:</span></td>
	    </tr>
		<tr valign="baseline">
	    <td width="4%">&nbsp;</td>
	      <td width="13%"><strong><span class="titulos">Unidade</span></strong></td>
	      <td width="83%"><span class="exibir"><strong>
	        <select name="lotacao_uni" class="form">
	          <option selected="selected" value="---">---</option>
	          <cfoutput query="request.qUnidade">
	            <option value="#und_Codigo#">#und_Descricao#</option>
	          </cfoutput>
	        </select>
	      </strong></span></td><br>
    </tr>
		 <tr valign="baseline">
		  <td width="4%">&nbsp;</td>
	      <td width="13%"><strong><span class="titulos">Órgão Subordinador</span></strong></td>
	      <td width="83%"><span class="exibir"><strong>
	        <select name="lotacao_reop" class="form">
	          <option selected="selected" value="---">---</option>
	          <cfoutput query="request.qReop">
	            <option value="#Rep_Codigo#">#Rep_Nome#</option>
	          </cfoutput>
	        </select>
	      </strong></span></td><br>
    </tr>
		  <tr valign="baseline">
		    <td>&nbsp;</td>
		    <td><strong><span class="titulos">Área</span></strong></td>
		    <td><span class="exibir"><strong><strong>
		      <select name="lotacao_usu" class="form">
                <option selected="selected" value="---">---</option>
                <cfoutput query="request.qArea2">
                  <option value="#Ars_Codigo#">#Ars_Descricao#</option>
                </cfoutput>
              </select>
		    </strong></strong></span></td>
	      </tr>
		  <tr valign="baseline">
		    <td>&nbsp;</td>
		    <td><strong><span class="titulos">Departamento</span></strong></td>
			<cfquery name="rsDepto" datasource="#dsn_inspecao#">
		 SELECT Dep_Codigo, Dep_Descricao FROM Departamento ORDER BY Dep_Descricao
		</cfquery>
		    <td><span class="exibir"><strong><strong><strong><strong>
		      <select name="departamento" class="form" id="departamento">
                <option selected="selected" value="---">---</option>
                <cfoutput query="rsDepto">
                  <option value="#Dep_Codigo#">#Dep_Descricao#</option>
                </cfoutput>
              </select>
		    </strong></strong></strong></strong></span></td>
	      </tr>
		  <tr valign="baseline">
		  <td width="4%">&nbsp;</td>
	      <td width="13%"><strong><span class="titulos">Superintend&ecirc;ncia</span></strong></td>
		 <cfquery name="rsSuper" datasource="#dsn_inspecao#">
		 SELECT Dir_Sto, Dir_Descricao FROM Diretoria where Dir_Sto is not null ORDER BY Dir_Sto
		</cfquery>
	      <td width="83%"><span class="exibir"><strong><strong><strong><strong>
	        <select name="superintendencia" class="form" id="superintendencia">
              <option selected="selected" value="---">---</option>
              <cfoutput query="rsSuper">
                <option value="#Dir_Sto#">#Dir_Descricao#</option>
              </cfoutput>
            </select>
	      </strong></strong>
	      </strong>
	      </strong></span></td>
	      <br>
	      </tr>
		<!---   <tr valign="baseline">
		  <td width="4%">&nbsp;</td>
	      <td width="13%"><strong><span class="titulos">Superintendência</span></strong></td>
	      <td width="83%"><span class="exibir"><strong>
	        <select name="lotacao_se" class="form">
 			 <option selected="selected" value="">---</option>
	          <cfoutput query="request.qSE">
	            <option value="#Dir_Codigo#">#Dir_Sigla#</option>
	          </cfoutput>
	        </select>
	      </strong></span></td><br>
	      </tr>
		  <tr valign="baseline">
		  <td width="4%">&nbsp;</td>
	      <td width="13%"><strong><span class="titulos">Área Sede</span></strong></td>
	      <td width="83%"><span class="exibir"><strong>
	        <select name="lotacao_cs" class="form">
	          <option selected="selected" value="">---</option>
	          <cfoutput query="request.qCS">
	            <option value="#Ars_Codigo#">#Ars_Sigla#</option>
	          </cfoutput>
	        </select>
	      </strong></span></td><br>
	      </tr> --->
	      	    <tr valign="baseline">
	      <td colspan="6">&nbsp;</td>
	    </tr>
			 <tr valign="baseline" align="center">

				<td colspan="2">
 				  <button type="button" class="botao" onClick="voltar();">Voltar</button>
				</td>
				<td colspan="3">
				  <button type="button" class="botao" onClick="incluir(dominio.value,matr_usu.value,apelido_usu.value,area_usu.value,lotacao_uni.value,lotacao_reop.value,lotacao_usu.value,departamento.value,superintendencia.value,'inc');">Confirmar a Permissão</button>
				</td>
          	 </tr>

	</table>
 </form>
	  <table width="85%" border="0" align="center">
	  <tr bgcolor="f7f7f7">
	     <td colspan="6" align="center" class="titulos">PERMISSÕES CONCEDIDAS</td>
	  </tr>

	    <tr bgcolor="eeeeee" class="exibir" align="center">
	  	<td width="17%">GRUPO DE ACESSO</td>
		<td width="23%">LOTA&Ccedil;&Atilde;O</td>
		<td width="9%">MATRICULA</td>
		<td width="21%">NOME</td>
		<td width="23%">LOGIN</td>
		<td width="7%">&nbsp;</td>
	  </tr>

	  <cfif qPermissoes.recordcount neq 0>
		  <cfoutput query="qPermissoes">
 		     <form action="" method="POST" name="formexc">
				 <cfset cpf = Usu_Matricula>
				 <cfset mat = Usu_Matricula>
				  <cfset matricula = Left(mat,1) & '.' & Mid(mat,2,3) & '.' & Mid(mat,5,3) & '-' &  Mid(mat,8,1)>
				  <cfset vCPF = Left(cpf,3) & '.' & Mid(cpf,4,3) & '.' & Mid(cpf,7,3) & '-' &  Mid(cpf,10,2)>
				  <tr valign="middle" bgcolor="f7f7f7" class="exibir"><td>#Usu_GrupoAcesso#</td>
				  <td>#Usu_LotacaoNome#</td>
					<cfif Left(Usu_login,11) eq 'CORREIOSNET'>
					  <cfset matricula = matricula>
					<cfelse>
					  <cfset matricula = vCPF>
					</cfif>
					<td><div align="center">#matricula#</div></td>
					<td>#Usu_Apelido#</td>
					<td>#Usu_login#</td>
					
						<input type="hidden" name="area" value="#Usu_GrupoAcesso#">
						<input type="hidden" name="matricula" value="#Usu_Matricula#">
						<input type="hidden" name="login" value="#Usu_Login#">
						<input type="hidden" name="apelido" value="#Usu_Apelido#">
						<input type="hidden" name="gerencia" value="#Usu_Lotacao#">
						<input type="hidden" name="outros" value="#Usu_Lotacao#">
						<td>
						  <div align="center">
						    <button name="submitAlt" type="button" class="botao" onClick="excluir(area.value,login.value,'exc');">
						  Excluir</button>
			        </div></td>
			  </tr>
		    </form>
		  </cfoutput>
	  </cfif>
	
	  <tr bgcolor="eeeeee">
	  <td colspan="6">&nbsp;</td>
	  </tr><a href="adicionar_permissao_rotinas_inspecao_novo.html">#DR#</a> 
    </table>

	<!--- FIM DA ÁREA DE CONTEÚDO --->

	</table>
	
<form name="formvolta" method="post" action="adicionar_permissao_rotinas_inspecao_novo1.cfm?flush=true">
<!---   <input name="sfrmPorNumPac" type="hidden" id="sfrmPorNumPac" value="<cfoutput>#sfrmPorNumPac#</cfoutput>"> 
  <input name="sfrmbusca" type="hidden" id="sfrmbusca" value="<cfoutput>#sfrmbusca#</cfoutput>">
  <input name="sfrmstatus" type="hidden" id="sfrmstatus" value="<cfoutput>#sfrmstatus#</cfoutput>">
 --->
</form> 
<form name="formx" method="POST" action="CFC/rotinas_permissoes_in_out.cfc?method=altexc">
  <input name="ssuper" type="hidden" id="ssuper" value="<cfoutput>#ssuper#</cfoutput>">
  <input name="slabel" type="hidden" id="slabel" value="<cfoutput>#slabel#</cfoutput>">
  <input name="sarea_ga" type="hidden" id="sarea_ga">
  <input name="smatr_usu" type="hidden" id="smatr_usu">
  <input name="slogin" type="hidden" id="slogin">
  <input name="sapelido_usu" type="hidden" id="sapelido_usu">
  <input name="sgerencia" type="hidden" id="sgerencia">
  <input name="soutros" type="hidden" id="soutros">
<!--- dados para inclusão --->
  <input name="sdominio" type="hidden" id="sdominio">  
  <input name="sarea_usu" type="hidden" id="sarea_usu">
  <input name="slotacao_uni" type="hidden" id="slotacao_uni">
  <input name="slotacao_reop" type="hidden" id="slotacao_reop">
  <input name="slotacao_usu" type="hidden" id="slotacao_usu">
  <input name="slotacao_se" type="hidden" id="slotacao_se">
  <input name="slotacao_cs" type="hidden" id="slotacao_cs">
  <input name="sdepartamento" type="hidden" id="sdepartamento">
  <input name="ssuperintendencia" type="hidden" id="ssuperintendencia">
  <input name="sacao" type="hidden" id="sacao">
  <!--- Término da área de conteúdo --->
</form>
</body>
</html>

