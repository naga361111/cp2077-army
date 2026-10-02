// Codeware 로컬라이즈: TweakDB 의 LocKey#Army-* 키에 텍스트 제공
import Codeware.Localization.*

public class ArmyLocalizationProvider extends ModLocalizationProvider {
  public func GetPackage(language: CName) -> ref<ModLocalizationPackage> {
    switch language {
      case n"ko-kr": return new ArmyKorean();
      case n"en-us": return new ArmyEnglish();
      default: return null;
    }
  }

  public func GetFallback() -> CName {
    return n"en-us";
  }
}

public class ArmyEnglish extends ModLocalizationPackage {
  protected func DefineTexts() -> Void {
    this.Text("Army-Faction-Name", "Army");
    this.Text("Army-Soldier-Name", "Army Soldier");
  }
}

public class ArmyKorean extends ModLocalizationPackage {
  protected func DefineTexts() -> Void {
    this.Text("Army-Faction-Name", "군대");
    this.Text("Army-Soldier-Name", "군대 병사");
  }
}
