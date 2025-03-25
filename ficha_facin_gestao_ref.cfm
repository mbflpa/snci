<cfprocessingdirective pageEncoding ="utf-8">

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
  SELECT Usu_GrupoAcesso, Usu_DR, Dir_Sigla, Usu_Coordena, Dir_Descricao, Usu_Matricula,Usu_AtivFacin
  FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR 
  WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
  order by Dir_Sigla
</cfquery>

<cfquery name="rsAnoPacin" datasource="#dsn_inspecao#">    
    SELECT PTC_Ano 
    FROM Pontuacao 
    GROUP BY PTC_Ano 
    HAVING (PTC_Ano) >= 2018
    order by PTC_Ano desc
</cfquery>   

<cfset auxanoatu = year(now())>
<cfquery name="rsAno" datasource="#dsn_inspecao#">
  SELECT Andt_AnoExerc
  FROM Andamento_Temp
  GROUP BY Andt_AnoExerc
  HAVING Andt_AnoExerc  < '#auxanoatu#'
  ORDER BY Andt_AnoExerc DESC
</cfquery>
<cfset auxse = ''>
<cfset AtivFacin = ucase(trim(qAcesso.Usu_AtivFacin))>
<cfloop list="#AtivFacin#" index="i">
  <cfset auxcol = "#i#">
  <cfset auxse = auxcol>
</cfloop>  
<!--- =========================== --->

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="public/bootstrap/bootstrap.min.css">  
 <link href="css.css" rel="stylesheet" type="text/css">
</head>
<br>
<body>

<!--- <cfinclude template="cabecalho.cfm"> --->
<tr>
   <td colspan="6" align="center">&nbsp;</td>
</tr>

<!--- �rea de conte�do   --->
	<form action="Pacin_Unidades_Avaliacao.cfm" method="post" target="_blank" name="frmObjeto" onSubmit="return validarform()">
	  <table width="30%" align="center">
       
        <tr>
          <td colspan="5" align="center" class="titulo2"><div class="row" align="center"><strong>FICHA DE AVALIAÇÃO (FACIN) - RESULTADOS</strong></div></td>
        </tr>
		    <tr>
          <td colspan="5" align="center" class="titulo1">&nbsp;</td>
        </tr>
        <tr>
          <td colspan="5" align="center">&nbsp;</td>
        </tr>

        <tr>
          <td width="2%"></td>
          <td colspan="4"><strong>
          </strong><strong><span class="exibir">
          </span></strong></td>
        </tr> 
        <cfset cont = 0>		  
        <tr>
            <td>&nbsp;</td>
            <td class="exibir"><strong>Exercício &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: </strong></td>
            <td colspan="2">
                <select name="frmano" id="frmano" class="form-select">
                    <cfloop query="rsAnoPacin">                                             
                        <option value="<cfoutput>#rsAnoPacin.PTC_Ano#</cfoutput>"><cfoutput>#rsAnoPacin.PTC_Ano#</cfoutput></option>
                    </cfloop>
                </select>
            </td>
        </tr>
        <tr><td>&nbsp;</td></tr>
        <tr>
          <td>&nbsp;</td>
          <td class="exibir"><strong>Período&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: </strong></td>
          <td>         
            <div class="row" align="left">
              <div class="col" align="center">
                Início
              </div>
            </div>        
          </td>
          <td>            
            <div class="row" align="left">
              <div class="col" align="center">
                Final
              </div>
            </div>  
          </td>
        </tr> 
        <tr>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>
            <div class="row" align="left">
              <div class="col" align="left">
                <input class="form-control" id="dtinic" name="dtinic" type="date" placeholder="DD/MM/AAAA">
              </div>
            </div>
          </td>
          <td>
            <div class="row" align="left">
              <div class="col" align="left">
                <input class="form-control" id="dtfinal" name="dtfinal" type="date" placeholder="DD/MM/AAAA">
              </div>
            </div>
          </td>
        </tr> 
        <tr>
          <td>&nbsp;</td>
        </tr>  
        <tr>
          <td>&nbsp;</td>
          <td width="39%" class="exibir"><strong>Superintendência: </strong></td>
          <td width="59%" colspan="2">
          <cfif auxse eq 'D'>	
                  <select name="frmse" id="frmse" class="form-select">
                        <option value="" selected>---</option>
                        <option value="<cfoutput>#qAcesso.Usu_DR#</cfoutput>"><cfoutput>#qAcesso.Dir_Sigla#</cfoutput></option>
                  </select>	
          <cfelse>
                <cfset auxcord = trim(qAcesso.Usu_Coordena)>
                <cfquery name="rsSE" datasource="#dsn_inspecao#">
                  SELECT Dir_Codigo, Dir_Sigla FROM Diretoria where dir_codigo in(#auxcord#)
                </cfquery>
                <select name="frmse" id="frmse" class="form-select">
                  <option value="" selected>---</option>
                  <cfoutput query="rsSE">
                        <option value="#rsSE.Dir_Codigo#">#Ucase(trim(rsSE.Dir_Sigla))#</option>
                  </cfoutput>
                </select>    
          </cfif>	
          <br>		
          </td>
        </tr>              
        <tr>
          <td>&nbsp;</td>
          <td class="exibir"><strong>Inspetores&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: </strong></td>
          <td colspan="2">
              <select name="frminspetores" id="frminspetores" class="form-select">                                          
                      <option value="">---</option>
              </select>
          </td>
        </tr> 
        <tr><td>&nbsp;</td></tr>
        <tr>
          <td>&nbsp;</td>
          <td class="exibir"><strong>Avaliações&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: </strong></td>
          <td colspan="2">
              <select name="frmavaliacao" id="frmavaliacao" class="form-select">                                          
                  <option value="">---</option>
              </select>
          </td>
        </tr>  
        <tr><td>&nbsp;</td></tr>  
        <tr><td>&nbsp;</td></tr>             
        <tr> 
          <td>&nbsp;</td>
            <td colspan="3">
              <div  class="row" align="center">
           <!---     <input name="Submit1" type="submit" class="btn btn-primary" id="Submit1" value="Confirmar"> --->
              </div></td>
          </tr>
          <tr>
          <td>&nbsp;</td>
          <td colspan="3">&nbsp;</td>
          </tr>
      </table>
      <!---  style="display:none;" --->
	    <div id='table'>
      </div>
<!--- 	  <input name="grupoacesso" type="hidden" value="<cfoutput>#qAcesso.Usu_GrupoAcesso#</cfoutput>">
	  <input name="usucoordena" type="hidden" value="<cfoutput>#qAcesso.Usu_Coordena#</cfoutput>"> --->
	</form>
</body>
<script src="public/jquery-3.7.1.min.js"></script>
<script type="text/javascript" src="public/axios.min.js"></script>
<script>
      //buscar o inspetores
      $('#frmse').change(function(e){ 
        let prots = '<option value="" selected>---</option>';
        let dtinic = $('#dtinic').val() 
        dtinic += ' 23:59:59.000'
        let dtfinal = $('#dtfinal').val()
        dtfinal += ' 23:59:59.000'
        if(dtinic == '' || dtfinal == ''){
          alert('Selecionar o período (Início/Final) da FACIN')
          $('#dtinic').focus()
          return false
         }
        if($(this).val() != ''){     
            let ano = $('#frmano').val(); 
            let frmse = $(this).val(); 
            axios.get("CFC/fichafacin.cfc",{
                params: {
                    method: "inspetores",
                    ano: ano,
                    dtinic: dtinic,
                    dtfinal: dtfinal,
                    codse: frmse
                }
            })
            .then(data =>{
            var vlr_ini = data.data.indexOf("COLUMNS");
            var vlr_fin = data.data.length
            vlr_ini = (vlr_ini - 2);
            const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
            const dados = json.DATA;
            dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
            });
            $("#frminspetores").html(prots);
            })  
        }
      })//fim buscar inspetores 
      //buscar o avaliações
      $('#frminspetores').change(function(e){ 
        let prots = '<option value="" selected>---</option>';
        prots += '<option value="t">Todas</option>'
        if($(this).val() != ''){    
            let dtinic = $('#dtinic').val() 
            dtinic += ' 23:59:59.000'
            let dtfinal = $('#dtfinal').val()
            dtfinal += ' 23:59:59.000'
            let ano = $('#frmano').val(); 
            let frmse = $('#frmse').val(); 
            let matr = $(this).val(); 
            //alert(ano + ' ' + frmse + ' ' + matr)
            axios.get("CFC/fichafacin.cfc",{
                params: {
                    method: "avaliacao",
                    ano: ano,
                    codse: frmse,
                    dtinic: dtinic,
                    dtfinal: dtfinal,
                    matr: matr
                }
            })
            .then(data =>{
            var vlr_ini = data.data.indexOf("COLUMNS");
            var vlr_fin = data.data.length
            vlr_ini = (vlr_ini - 2);
            const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
            const dados = json.DATA;
            dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[0]+'-'+ret[1] + '</option>';
            });
            $("#frmavaliacao").html(prots);
            })  
        }
      })//fim buscar avaliações   
      //preencher tabela
      $('#frmavaliacao').change(function(e){ 
        $("#table").hide(500)
        if($(this).val() != ''){    
            let aval = $(this).val()
            let matr = $('#frminspetores').val(); 
            //alert(ano + ' ' + frmse + ' ' + matr)
            axios.get("CFC/fichafacin.cfc",{
                params: {
                    method: "gestao",
                    aval: aval,
                    matr: matr
                }
            })
            .then(data =>{
              let numocor = 0
              let medmeta1 = 0
              let medmeta2 = 0
              let medmeta3 = 0
              let tab = '<table class="table table-bordered border-primary">'
              tab += '<thead>'
              tab += '<tr>'
              tab +=  '<th scope="col">Nº Avaliação</th>'
              tab +=  '<th scope="col">Tipo</th>'
              tab +=  '<th scope="col">Qtd. Geral</th>'
              tab +=  '<th scope="col">Qtd. Realizado</th>'
              tab +=  '<th scope="col">Desconto(Meta1)</th>'
              tab +=  '<th scope="col">Pto. Obtida(Meta1)</th>'
              tab +=  '<th scope="col">Resultado(Meta1)</th>'
              tab +=  '<th scope="col">Desconto(Meta2)</th>'
              tab +=  '<th scope="col">Pto. Obtida(Meta2)</th>'
              tab +=  '<th scope="col">Resultado(Meta2)</th>'
              tab +=  '<th scope="col">Perc.(Meta3)</th>'
              tab += '</tr>'
              tab += '</thead>'
              tab += '<tbody>'
              var vlr_ini = data.data.indexOf("COLUMNS");
              var vlr_fin = data.data.length
              vlr_ini = (vlr_ini - 2);
              const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
              const dados = json.DATA;
              //FFI_Avaliacao,TUN_Descricao,FAC_Qtd_Geral,FFI_Qtd_Item,FFI_Meta1_Pontuacao_Obtida,FFI_Meta1_Resultado,FFI_Meta2_Pontuacao_Obtida,FFI_Meta2_Resultado,FAC_Perc_Meta3
              dados.map((ret) => {
                numocor++
                medmeta1 = medmeta1 + ret[5]
                medmeta2 = medmeta2 + ret[7]
                medmeta3 = medmeta3 + ret[8]
                descmeta1 = eval(ret[3] - ret[4]).toFixed(2)
                if(descmeta1 < 0){descmeta1=0}
                descmeta2 = eval(ret[3] - ret[6]).toFixed(2)
                if(descmeta2 < 0){descmeta2=0}
                let url = 'href=ficha_facin_gestao_relat.cfm?ninsp='+ret[0]+'&matr='+matr
                //alert(url)
                tab += '<tr>'
                  tab += '<td class="alert alert-primary"><a class="alert-link" '+url+' target="_blank">'+ret[0]+'</a></td>'
                  tab += '<td>'+ret[1]+'</td>'
                  tab += '<td>'+ret[2]+'</td>'
                  tab += '<td>'+ret[3]+'</td>'
                  tab += '<td>'+descmeta1+'</td>'
                  tab += '<td>'+eval(ret[4]).toFixed(2)+'</td>'
                  tab += '<td>'+eval(ret[5]).toFixed(2)+'</td>'
                  tab += '<td>'+descmeta2+'</td>'
                  tab += '<td>'+eval(ret[6]).toFixed(2)+'</td>'
                  tab += '<td>'+eval(ret[7]).toFixed(2)+'</td>'
                  tab += '<td>'+eval(ret[8]).toFixed(2)+'</td>'
                tab += '</tr>'
              });
              tab += '<tr>'
                tab += '<td>Médias</td>'
                tab += '<td></td>'
                tab += '<td></td>'
                tab += '<td></td>'
                tab += '<td></td>'
                tab += '<td></td>'
                tab += '<td>'+eval(medmeta1/numocor).toFixed(2)+'</td>'
                tab += '<td></td>'
                tab += '<td></td>'
                tab += '<td>'+eval(medmeta2/numocor).toFixed(2)+'</td>'
                tab += '<td>'+eval(medmeta3/numocor).toFixed(2)+'</td>'
              tab += '</tr>'
              tab += '</tbody>'
              tab += '</table>'              
              $("#table").html(tab);
              $("#table").show(500)
            })  
        }
      })//fim preencher tabela            
      //Limpar os selects bases   
      $('#frmano').change(function() {
        $("#frmse").val("").change();
        let prots = '<option value="" selected>---</option>';
        $("#frminspetores").html(prots);
        $("#frmavaliacao").html(prots);
        $("#table").hide(500)
      }); 
      $('#frmse').change(function() {
        let prots = '<option value="" selected>---</option>';
        $("#frminspetores").html(prots);
        $("#frmavaliacao").html(prots);
        $("#table").hide(500)
      }); 
      $('#frminspetores').change(function() {
        let prots = '<option value="" selected>---</option>';
        $("#frmavaliacao").html(prots);
        $("#table").hide(500)
      });
      $('#dtinic').change(function() {
        $("#frmse").val("").change();
        let prots = '<option value="" selected>---</option>';
        $("#frminspetores").html(prots);
        $("#frmavaliacao").html(prots);
        $("#table").hide(500)
      });
      $('#dtfinal').change(function() {
        $("#frmse").val("").change();
        let prots = '<option value="" selected>---</option>';
        $("#frminspetores").html(prots);
        $("#frmavaliacao").html(prots);
        $("#table").hide(500)
      }); 
      //final Limpar os selects bases
      $(".external").attr("target","_blank")
</script>
</html>
