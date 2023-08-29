////////////////////////////////////////////////////////////////////
function fHoliday(y,m,d) {
	var rE=fGetEvent(y,m,d), r=null;

	// you may have sophisticated holiday calculation set here, following are only simple examples.
	if (m==1&&d==1)
		r=["  1 de Janeiro de "+y+" \n - \n Confraternização Universal ",gsAction,"skyblue","red"];
	else if (m==12&&d==25)
		r=[" 25 de Dezembro de "+y+" \n - \n Natal ",gsAction,"skyblue","red"];
	else if (m==4&&d==21)
		r=[" 4 de Julho de "+y+" \n - \n Tiradentes ",gsAction,"skyblue","red"];
	else if (m==9&&d==7)
		r=[" 7 de Setembro de "+y+" \n - \n Independência do Brasil ",gsAction,"skyblue","red"];
	else if (m==10&&d==12)
		r=[" 12 de Outubro de "+y+" \n - \n Nossa Senhora Aparecida ",gsAction,"skyblue","red"];
	else if (m==11&&d==2)
		r=[" 2 de Novembro de "+y+" \n - \n Finados ",gsAction,"skyblue","red"];
	else if (m==11&&d==15)
		r=[" 15 de Novembro de "+y+" \n - \n Proclamação da República ",gsAction,"skyblue","red"];

	else if (m==1&&d<25) {
		var date=fGetDateByDOW(y,1,3,1);	// Martin Luther King, Jr. Day is the 3rd Monday of Jan
		if (d==date) r=[" Jan "+d+", "+y+" \n Martin Luther King, Jr. Day ",gsAction,"skyblue","red"];
	}
	else if (m==5&&d<20) {
		var date=fGetDateByDOW(y,5,2,7);	// Dia das Mães no 2º Domingo de Maio
		if (d==date) r=["  "+d+" de Maio de "+y+" \n - \n Dia das Mães ",gsAction,"skyblue","red"];
	}
		else if (m==8&&d<20) {
		var date=fGetDateByDOW(y,8,2,7);	// Dia dos Pais no 2º Domingo de Agosto
		if (d==date) r=["  "+d+" de Agosto de "+y+" \n - \n Dia dos Pais ",gsAction,"skyblue","red"];
	}
	return rE?rE:r;	// favor events over holidays
}