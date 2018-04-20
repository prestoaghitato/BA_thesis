package run;

import java.util.ArrayList;

import com.sun.javafx.font.directwrite.DWFactory;

import IO.DataReader;
import IO.DataWriter;
import core.AssocRule;
import core.AssocRuleSet;
import core.SequenceSet;
import util.ArrayUtil;
import util.PrintUtil;
import util.Set;

public class LocalRun {
	
	public static void main(String[] args)
	{
//		DataReader dr = new DataReader();
//		
//		String url = "C:\\Users\\client\\Desktop\\PHD\\Psycholinguistic\\DatenClean";
//		
//		SequenceSet seqS = dr.extractSequences(dr.readRoughtData(url));
//		
//		
//		String desURL = "C:\\Users\\client\\Desktop\\PHD\\Psycholinguistic\\DatenSPMF";
//		String desFile = "datenSPMF.txt";
//		
//		DataWriter dw = new DataWriter();
//		dw.writeSequenceSetSPMF(desURL, desFile, seqS);
//		dw.writeFile(desURL + "\\labelTabel.txt", seqS.toStringTable());
//		
//		ArrayList<String[]> rawS = new ArrayList<>();
//		
//		rawS.add(new String[]{"A","1","3"});
//		rawS.add(new String[]{"B","3","6"});
//		rawS.add(new String[]{"C","4","8.5"});
//		rawS.add(new String[]{"A","4","8"});
//		rawS.add(new String[]{"D","0","9"});
//		
//		SequenceSet seqSet = new SequenceSet();
//		
//		seqSet.buildSequence(rawS);
//		
//		System.out.println(seqSet.toString());
//		AssocRuleSet ars = seqSet.buildAssocRules();
//		
//		System.out.println(ars.rulesToString());
		
//		Exp1 exp = new Exp1();
//		exp.run();
		
		Exp2 exp = new Exp2();
		exp.run2();
		
//		String s = "test";
//		int i1 = 30;
//		int i2 = 20;
//		
//		StringBuffer sb = new StringBuffer();
//		sb.append(String.format("%" + (i1-i2) + "s","test") + "text");
//		
//		System.out.println(sb.toString());
		
		
//		int[] iA = {1,2,3,4,5};
		
//		int[][] subS = ArrayUtil.subsets(iA);
		
//System.out.println(PrintUtil.print2DArray(subS));
		
//		ArrayList<int[][]> pS = ArrayUtil.powerSet(iA);
//		
//		for(int[][] dA: pS)
//		{
//			System.out.println(PrintUtil.print2DArray(dA));
//		}
		
//		String[][] far = {	{"ingressive", "VOC"},
//						{"closant","VOC"},
//						{"raspberry","VOC"},
//						{"vowel","VOC"},
//						{"variegated","VOC"},
//						{"whisper","VOC"},
//						{"closant?","VOC"},
//						{"closanr","VOC"},
//						{"growl","VOC"},
//						{"yell","VOC"},
//						{"squeal","VOC"},
//						{"wisper","VOC"},
//						{"reduplicated","VOC"},
//						{"marginal","VOC"},
//						{"whisper?","VOC"},
//						{"-gaze","_gaze"},
//						{"M-voc","Mother-speech"}
//						};
//		
//		String srcDir = "C:\\Users\\client\\Desktop\\PHD\\Psycholinguistic\\Daten";
//		String desDir = "C:\\Users\\client\\Desktop\\PHD\\Psycholinguistic\\DatenClean";
//		
//		DataWriter dw = new DataWriter();
//		dw.replace(srcDir, desDir, far);
//		
	}

}
