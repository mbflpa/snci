<cfprocessingdirective pageEncoding ="utf-8"/>
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
   <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>          
	<!--- <cfoutput>#form.dr# #form.area_usu#</cfoutput> --->
 <cfif isDefined("url.frmse") and #url.frmse# neq ''>
   <cfset form.frmse = url.frmse>
   <cfset form.frmano = url.frmano>   
 </cfif> 
	
	<cfquery name="qAcesso" datasource="#dsn_inspecao#">
		SELECT Usu_GrupoAcesso, Usu_DR, Dir_Sigla, Usu_Coordena
		FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR 
		WHERE Usu_DR = '#form.frmse#'
	</cfquery> 


	<cfquery name="rsUnidade" datasource="#dsn_inspecao#">
		SELECT PPU_DEUnidade, Unidades.Und_Descricao, Unidades.Und_Ano_Horas_Avaliar, Unidades.Und_Ano_Pontos_Avaliar, PPU_PARAUnidade, Unidades_1.Und_Descricao as unidpara, Unidades_1.Und_Ano_Horas_Avaliar as hh, Unidades_1.Und_Ano_Pontos_Avaliar as pto, PPU_Motivo
		FROM Unidades AS Unidades_1 INNER JOIN (PacinPermutaUnidade INNER JOIN Unidades ON PPU_DEUnidade = Unidades.Und_Codigo) ON Unidades_1.Und_Codigo = PPU_PARAUnidade
		WHERE PPU_Ano ='#form.frmano#' and PPU_Status = 'S' 
		and left(PPU_DEUnidade,2) = '#form.frmse#'
		ORDER BY Unidades.Und_Descricao
	</cfquery>
		
	<html>
	<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>Sistema Nacional de Controle Interno</title>
	<link href="../../estilo.css" rel="stylesheet" type="text/css">
	<link href="css.css" rel="stylesheet" type="text/css">
<script type="text/javascript">
// função que transmite as rotinas de alt, exc, etc...
//=============================
function alterar(a,b){
	document.formx.frmunidde.value=a;
	document.formx.frmunidpara.value=b;
	document.formx.submit(); 
}

</script>
<script language="JavaScript" src="../../mm_menu.js"></script>
	<style type="text/css">
<!--
.style1 {color: #FFFFFF}
-->
    </style>
	</head>

<body>


<cfinclude template="cabecalho.cfm">
	    <span class="exibir"><strong>
	    </strong></span>
        <table width="67%" border="0" align="center">
          <tr valign="baseline">
            <td colspan="2" class="exibir">&nbsp;</td>
          </tr>
          <tr valign="baseline">
            <td colspan="2" class="exibir"><div align="center"><STRONG>AUTORIZAR SUBSTITUIÇÃO DE UNIDADE PARA AVALIAÇÃO NO PACIN</STRONG></div></td>
          </tr>
          <tr valign="baseline">
            <td colspan="2">&nbsp;</td>
          </tr>
	  
          <cfoutput>
            <tr valign="baseline">
              <td width="48%"><div align="center"><span class="titulos">Superintendência:</span>
                  <select name="dr" id="dr" class="form" disabled>
                    <option selected="selected" value="#qAcesso.Usu_DR#">#qAcesso.Dir_Sigla#</option>
                </select>
              </div></td>
              <td width="52%"><div align="center"><span class="titulos">Exercício:</span>
                  <select name="frmano" id="frmano" class="form"" disabled>
                    <option value="#frmano#">#frmano#</option>
                </select>
              </div></td>
            </tr>
          </cfoutput>
        </table>

	    <table width="93%" border="0" align="center">
          <form action="" method="post" target="_parent" name="form2">
            <tr bgcolor="f7f7f7">
              <td width="14%" align="center" bgcolor="f7f7f7" class="titulo1">&nbsp;</td>
            </tr>
            <tr bgcolor="f7f7f7">
              <td colspan="7" align="center" bgcolor="#CCCCCC" class="titulo1"> Unidade(s) SOLICITADAS PARA PERMUTA DE AVALIAÇÃO NO PACIN de <cfoutput>#form.frmano#</cfoutput></td>
             
            </tr>
			<tr class="titulosClaro">
              <td colspan="7" bgcolor="eeeeee" class="exibir"><cfoutput>Qtd. #rsUnidade.recordcount#</cfoutput></td>
            </tr>
            <tr class="titulosClaro">
              <td colspan="7" bgcolor="eeeeee" class="exibir"><table width="100%" border="0">
                  <tr bgcolor="#CCCCCC" class="titulos">
                    <td colspan="5" bgcolor="#FF3300"><div align="center" class="style1">DE</div></td>
                    <td colspan="4" bgcolor="#33CCFF"><div align="center">PARA</div></td>
                    <td>&nbsp;</td>
                  </tr>
                  <tr bgcolor="#CCCCCC" class="titulos">
                    <td width="5%">Unidade </td>
                    <td width="27%" bgcolor="#CCCCCC">Nome da Unidade </td>
                    <td width="17%" bgcolor="#CCCCCC">Motivo</td>
                    <td width="4%" bgcolor="#CCCCCC"><div align="center">Horas</div></td>
                    <td width="5%" bgcolor="#CCCCCC"><div align="center">Pontos</div></td>
                    <td width="5%" bgcolor="#CCCCCC">Unidade</td>
                    <td width="17%" bgcolor="#CCCCCC">Nome da Unidade</td>
                    <td width="3%" bgcolor="#CCCCCC"><div align="center">Horas</div></td>
                    <td width="5%" bgcolor="#CCCCCC"><div align="center">Pontos</div></td>
                    <td width="12%"><div align="center">Ação </div></td>
                  </tr>
				  <cfset scor = 'f7f7f7'>

                  <cfoutput query="rsUnidade">
                      <tr class="titulos" bgcolor="#scor#">
					  	<cfset auxunid = PPU_DEUnidade>
                        <td>#auxunid#</td>
                        <td bgcolor="#scor#">#Und_Descricao#</td>
                        <td bgcolor="#scor#">#PPU_Motivo#</td>
						<cfset horas = Und_Ano_Horas_Avaliar>
                        <td bgcolor="#scor#"><div align="center">#horas#</div></td>
						<cfset pontos = numberFormat(Und_Ano_Pontos_Avaliar,99.00)>
                        <td bgcolor="#scor#"><div align="center">#pontos#</div></td>
						<cfset auxunid = PPU_PARAUnidade>
                        <td>#auxunid#</td>
                        <td>#unidpara#</td>
						<!--- <cfset horas = Und_Ano_Horas_Avaliar> --->
                        <td><div align="center">#hh#</div></td>
						<cfset pontos = numberFormat(pto,99.00)>
                        <td><div align="center">#pontos#</div></td>
                        <td bgcolor="#scor#"><div align="center">
                          <button name="submitAlt" type="button" class="botao" onClick="alterar('#PPU_DEUnidade#','#PPU_PARAUnidade#');">Selecionar Este</button>
                        </div></td>
                      </tr>
                      <cfif scor eq 'f7f7f7'>
                        <cfset scor = 'CCCCCC'>
                      <cfelse>
                        <cfset scor = 'f7f7f7'>
                      </cfif>
                  </cfoutput>
              </table></td>
            </tr>
            <tr>
              <td colspan="10">
			  <table width="100%" border="0">
                <tr>
                  <th scope="row"><div align="left">
                    <input name="Submit1" type="button" class="form" id="Submit1" value="FECHAR" onClick="window.close()">
                  </div></th>
                </tr>
              </table></td>
            </tr>

          </form>
          <!--- FIM DA ÁREA DE CONTEÚDO --->
</table>
<form name="formx" method="POST" action="Pacin_Permuta_Avaliacaob1.cfm">
	<input name="frmse" type="hidden" id="frmse" value="<cfoutput>#form.frmse#</cfoutput>">
	<input name="frmano" type="hidden" id="frmano" value="<cfoutput>#form.frmano#</cfoutput>">
	<input name="frmunidde" type="hidden" id="frmunidde" value="">
	<input name="frmunidpara" type="hidden" id="frmunidpara" value="">
</form>	

	    <!--- Término da área de conteúdo --->
</body>
</html>

