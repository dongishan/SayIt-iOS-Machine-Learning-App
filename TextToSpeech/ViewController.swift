//
//  ViewController.swift
//  TextToSpeech
//
//  Created by Gishan Don Ranasinghe on 08/12/2016.
//  Copyright © 2016 Gishan Don Ranasinghe. All rights reserved.
//

import UIKit
import TextToSpeechV1
import AVFoundation
import LanguageTranslatorV2

class ViewController: UIViewController, UITextFieldDelegate{
    
    var audioPlayer: AVAudioPlayer!
    var textToSpeechService : TextToSpeech!
    var langaugeTranslatorService : LanguageTranslator!
    
    @IBOutlet weak var originalTextTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textToSpeechService = TextToSpeech(username: "<your bluemix text to speech service username>", password: "your bluemix text to speech service password")
        langaugeTranslatorService = LanguageTranslator(username: "your bluemix language translator service username", password: "your bluemix language translator service password")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func doTranslate(_ sender: UIButton) {
        if let originalText = originalTextTextField.text{
            
            var toLanguage : String!
            var voiceModel : String!
            
            switch sender.tag{
            case 0:
                toLanguage = "fr-FR"
                voiceModel = "fr-FR_ReneeVoice"
            case 1:
                toLanguage = "de-DE"
                voiceModel = "de-DE_DieterVoice"
            case 2:
                toLanguage = "es-ES"
                voiceModel = "es-ES_LauraVoice"
            case 3:
                toLanguage = "it-IT"
                voiceModel = "it-IT_FrancescaVoice"
            default:
                toLanguage = "en-GB"
                voiceModel = "en-GB_KateVoice"
            }
            
            if toLanguage == "en-GB"{
                textToSpeech(text: originalText)
            }else{
                let translationFailure = { (error: Error) in print(error) }
                langaugeTranslatorService.translate(originalText, from: "en", to: toLanguage, failure: translationFailure) {
                    translation in
                    self.textToSpeech(voiceModel: voiceModel, toLanguage: toLanguage, translation: translation.translations[0].translation)
                }
            }
        }
    }
    
    /*Other Languages*/
    private func textToSpeech(voiceModel : String, toLanguage : String, translation : String){
        let speechFailure = { (error: Error) in print(error) }
        self.textToSpeechService.createCustomization(withName: "CustomVoiceModel", language: toLanguage, description: "Custom voice models for translated texts", failure:speechFailure, success: { (customization) in
            
            self.textToSpeechService.synthesize(translation, voice: voiceModel, customizationID: customization.customizationID, audioFormat: AudioFormat.wav, failure: { (error) in
            }, success: { (data) in
                self.audioPlayer = try! AVAudioPlayer(data: data)
                self.audioPlayer.play()
            })
        })
    }
    
    /*English*/
    private func textToSpeech(text : String){
        textToSpeechService.synthesize(text, success: {(data) in
                self.audioPlayer = try! AVAudioPlayer(data: data)
                self.audioPlayer.play()
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

