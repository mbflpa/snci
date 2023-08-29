<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Avaliações do Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<script language="javascript">
function Mascara_Data(data)
{
	switch (data.value.length)
	{
		case 2:
			data.value += "/";
			break;
		case 5:
			data.value += "/";
			break;
	}
}
</script>
<style type="text/css">
<!--
.style12 {font-size: 18px}
-->
</style>
<style type="text/css">
<!--
.style14 {color: #FF0000}
-->
</style>
<style type="text/css">
<!--
.style15 {color: #0033FF}
-->
</style>
<cfinclude template="cabecalho.cfm">
<link href="css.css" rel="stylesheet" type="text/css">
</head>

<body onLoad="frmObjeto.Submit22.focus()">
<p align="center" class="titulo1">Alterar datas da Avalição do Controle Interno</p>
</p>

<cfset num1 = form.num_insp>
<cfquery name="qInspetores" datasource="#dsn_inspecao#">
           SELECT Unidades.Und_Descricao
           FROM  Unidades INNER JOIN (Funcionarios INNER JOIN Inspetor_Inspecao ON                 Funcionarios.Fun_Matric = Inspetor_Inspecao.IPT_MatricInspetor) ON                 Unidades.Und_Codigo = Inspetor_Inspecao.IPT_CodUnidade
           WHERE (((Inspetor_Inspecao.IPT_NumInspecao)='#num1#'))
           GROUP BY Unidades.Und_Descricao;
</cfquery>





 
	<cfform
	
	 action="Alterar_datas_inspecao.cfm" method="Post" name="frmObjeto" o>
   	
      <div align="center">
        <table   width="45%" height="83" align="center" >
  <td height="8">
      <td height="8">  
  <tr>
    <cfif qInspetores.recordcount neq 0>
	
	<tr>
    <td width="40%" height="21"  class="exibir"><strong>N&ordm; da Inspe&ccedil;&atilde;o: </strong></td>
    <td width="60%"><cfoutput>
      <div align="left">
        <cfinput name="num_insp"   maxlength="10" tabindex="1" size="13" required="yes" value="#Form.num_insp#" validate="integer" class="form_invisivel" >
      </div>
    </cfoutput></td>
  </tr>
  
  <tr>
    <td height="21"><strong class="exibir">Data Inicial da Inspe&ccedil;&atilde;o:</strong></td>
    <td><cfoutput>
      <div align="left">
        <cfinput name="data_inicial" type="text" maxlength="10" tabindex="1" size="12" required="yes" value="#DateFormat(Form.data_inicial,"dd/mm/yyyy")#" message="Data Inicial inv&aacute;lida (dd/mm/aaaa)" class="form_invisivel" >
      </div>
    </cfoutput></td>
  </tr>
  <tr>
    <td height="21"><strong class="exibir"><strong>Data Final da Inspe&ccedil;&atilde;o:</strong></strong></td>
    <td><cfoutput>
      <div align="left">
        <cfinput name="data_final" type="text" size="12" maxlength="10" tabindex="2" required="yes"  value="#DateFormat(Form.data_final,"dd/mm/yyyy")#" message="Data Final inv&aacute;lida (dd/mm/aaaa)" class="form_invisivel" >
      </div>
    </cfoutput></td>
  </tr>
  </cfif>
        </table>
        <cfif qInspetores.recordcount  neq 1 and qInspetores.recordcount  neq 0 ><p class="style14">Cuidado! Existe mais de uma unidade cadastrada para o n&uacute;mero de inspe&ccedil;&atilde;o fornecido. &Eacute; recomendado         consultar o SGI antes de continuar. </p>
          <p class="style14">&nbsp;</p>
        </cfif>
      </div>
      <table width="45%" border="0" align="center" class="Tabela">
        
        
        <!--- Consulta Inspetores 01--->
        <cfset num = form.num_insp>
        <cfquery name="qInspetores2" datasource="#dsn_inspecao#">
          SELECT DISTINCT Unidades.Und_Descricao
          FROM Unidades INNER JOIN (Funcionarios INNER JOIN Inspetor_Inspecao ON               Funcionarios.Fun_Matric = Inspetor_Inspecao.IPT_MatricInspetor) ON               Unidades.Und_Codigo = Inspetor_Inspecao.IPT_CodUnidade
          WHERE (((Inspetor_Inspecao.IPT_NumInspecao)='#num#'))
          GROUP BY Unidades.Und_Descricao;
        </cfquery>
        <cfif qInspetores2.recordcount neq 0>
          <cfoutput query="qInspetores2">
            <tr valign="top" bgcolor="f7f7f7" class="exibir">
              <td width="40%" bgcolor="##FFFFFF"><strong>Unidade:</strong></td>
              <td width="60%" bgcolor="##FFFFFF">#Und_Descricao#</td>
            </tr>
          </cfoutput>
        </cfif>
		
		<cfif qInspetores2.recordcount EQ 0>
             <tr valign="top" bgcolor="f7f7f7" class="exibir" width="45%">
               <td bgcolor="#FFFFFF">&nbsp;</td>
              <td bgcolor="#FFFFFF"><div align="center"><span class="style12 style14"><strong>AVALIAÇÃO DE CONTROLE INTERNO NÃO CADASTRADA</strong></span></div></td>
            </tr>
        </cfif>
      </table>
	  <table width="45%" border="0" align="center" class="Tabela">
        <!--- Consulta Inspetores 01--->
        <cfset num = form.num_insp>
        <cfquery name="qInspetores3" datasource="#dsn_inspecao#">
          SELECT Inspecao.INP_NumInspecao, Funcionarios.Fun_Nome
          FROM Funcionarios INNER JOIN Inspecao ON Funcionarios.Fun_Matric =                Inspecao.INP_Coordenador
          WHERE (((Inspecao.INP_NumInspecao)='#num#'))
          ORDER BY Funcionarios.Fun_Nome;
        </cfquery>
        <cfif qInspetores3.recordcount neq 0>
          <cfoutput query="qInspetores3">
            <tr valign="top" bgcolor="f7f7f7" class="exibir">
              <td width="40%" bgcolor="##FFFFFF"><strong>Coordenador:</strong></td>
              <td width="60%" bgcolor="##FFFFFF"><div align="left">#Fun_Nome#</div></td>
            </tr>
          </cfoutput>
        </cfif>
        <cfif qInspetores2.recordcount EQ 0>
        </cfif>
      </table>
	  <p>&nbsp;</p>
	  <div align="right">
	    <cfif qInspetores.recordcount neq 0>
	      <table width="45%" border="0" align="center" class="Tabela">
	        <tr bgcolor="f7f7f7">
	          <td colspan="2" align="center" bgcolor="eeeeee" class="titulos"><div align="center">INSPETORES CADASTRADOS P/ ESSA AVALIAÇÃO DE CONTROLE INTERNO</div></td>
            </tr>
	        
	        <tr bgcolor="eeeeee" class="exibir" align="center">
	          <td width="27%"><strong>MATR&Iacute;CULA</strong></td>
	          <td width="73%" bgcolor="eeeeee"><strong>NOME</strong></td>
            </tr>
	        
	        
	        <!--- Consulta Inspetores 02 --->
            <cfset num = form.num_insp>
              <cfquery name="qInspetores" datasource="#dsn_inspecao#">
              SELECT Unidades.Und_Descricao, Funcionarios.Fun_Matric,                     Funcionarios.Fun_Nome
              FROM   Funcionarios INNER JOIN (Unidades INNER JOIN Inspetor_Inspecao                     ON Unidades.Und_Codigo = Inspetor_Inspecao.IPT_CodUnidade) ON                     Funcionarios.Fun_Matric = Inspetor_Inspecao.IPT_MatricInspetor
              WHERE  (((Inspetor_Inspecao.IPT_NumInspecao)='#num#'))
              GROUP  BY Unidades.Und_Descricao, Funcionarios.Fun_Matric,                     Funcionarios.Fun_Nome
              ORDER BY Funcionarios.Fun_Nome;
              </cfquery>
	        
	        <cfif qInspetores.recordcount neq 0>
	          <cfoutput query="qInspetores">
	            <tr valign="top" bgcolor="f7f7f7" class="exibir">
	              <td><div align="center">#Fun_Matric#</div></td>
	              <td>#Fun_Nome#</td>
                </tr>
              </cfoutput>
            </cfif>
          </table>
        </cfif>
      </div>
      <table width="191" align="center">
        
        <tr>
          <td width="365" height="29">            
            
            <div align="left">
			 <cfif qInspetores.recordcount neq 0>
              
               
               <div align="center">
                 <p>
                   <input name="Submit2" type="submit" class="botao" value=                               "Confirmar" >
				   
                 </p>
               </div>
			 </cfif>
		  </div></td>
        </tr>
      </table>
      <p>&nbsp;</p>
      <p>&nbsp;</p>
	</cfform>

</body>
</html>