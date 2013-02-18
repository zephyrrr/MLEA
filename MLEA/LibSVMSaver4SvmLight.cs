using java.lang;

namespace MLEA
{
    public class LibSVMSaver4SvmLight : weka.core.converters.LibSVMSaver
    {
        protected override string instanceToLibsvm(weka.core.Instance inst)
        {
            //StringBuffer.__<clinit>();
            //StringBuffer buffer = new StringBuffer(new StringBuilder().append("").append(inst.classValue()).toString());
            StringBuffer buffer = new StringBuffer(new StringBuilder().append("").append(inst.classValue() - 1).toString());
            for (int i = 0; i < inst.numAttributes(); i++)
            {
                if ((i != inst.classIndex()) && (inst.value(i) != 0f))
                {
                    buffer.append(new StringBuilder().append(" ").append((int)(i + 1)).append(":").append(inst.value(i)).toString());
                }
            }
            return buffer.toString();

        }
    }
}
