package run;

import java.util.ArrayList;

import IO.DataReader;
import IO.DataWriter;
import core.AssocRuleSet;
import core.SequenceSet;

public class Exp2 {
	
//	public void run()
//	{
//		DataReader dr = new DataReader();
//		
//		String url = "C:\\Users\\client\\Desktop\\PHD\\Psycholinguistic\\DatenClean";
//		
//		SequenceSet seqS = dr.extractSequences(dr.readRoughtData(url));
//		
//		
//		String desURL = "C:\\Users\\client\\Desktop\\PHD\\Psycholinguistic\\DatenAssRules";
//		String desFile = "datenAssRules.txt";
//		
//		DataWriter dw = new DataWriter();
//
//		dw.writeFile(desURL + "\\labelTabel.txt", seqS.toStringTable());
//	
//		AssocRuleSet ars = seqS.buildAssocRules();
//		
//		double conf = 0.5;
//		double CI = 0;
//		double SAI = 0;
//		
//		dw.writeFile(desURL + "\\" + desFile, ars.printFilter(conf, CI, SAI));
//		
//	}
	
	public void run2()
	{
		DataReader dr = new DataReader();
		
		String url = "C:\\Users\\client\\Desktop\\PHD\\Psycholinguistic\\DatenClean";
		
		SequenceSet seqS = dr.extractSequences(dr.readRoughtData(url));
		
		
		String desURL = "C:\\Users\\client\\Desktop\\PHD\\Psycholinguistic\\DatenAssRules";
		String desRuleFile = "datenAssRules.txt";
		String desFile = "patternCount.txt";
		
		DataWriter dw = new DataWriter();
	
		AssocRuleSet ars = seqS.buildAssocRules();
		
		dw.writeFile(desURL + "\\" + desRuleFile, ars.rulesToString());
		dw.writeFile(desURL + "\\" + desFile, ars.countAndDuration());
		
	}

}
