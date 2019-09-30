// GENERATED AUTOMATICALLY FROM 'Assets/Input/MAJIKAInput.inputactions'

using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.Utilities;

public class MAJIKAInput : IInputActionCollection
{
    private InputActionAsset asset;
    public MAJIKAInput()
    {
        asset = InputActionAsset.FromJson(@"{
    ""name"": ""MAJIKAInput"",
    ""maps"": [
        {
            ""name"": ""GamePlay"",
            ""id"": ""6f10c320-b22a-45a9-bf73-aab63e03b425"",
            ""actions"": [
                {
                    ""name"": ""Movement"",
                    ""id"": ""dae96b02-b97f-4f4b-89f8-24f12c6c322c"",
                    ""expectedControlLayout"": """",
                    ""continuous"": true,
                    ""passThrough"": false,
                    ""initialStateCheck"": false,
                    ""processors"": """",
                    ""interactions"": """",
                    ""bindings"": []
                },
                {
                    ""name"": ""Jump"",
                    ""id"": ""a6dfbb9b-4192-4352-8c88-5bb6cb8abfb3"",
                    ""expectedControlLayout"": """",
                    ""continuous"": true,
                    ""passThrough"": false,
                    ""initialStateCheck"": false,
                    ""processors"": """",
                    ""interactions"": """",
                    ""bindings"": []
                },
                {
                    ""name"": ""Climb"",
                    ""id"": ""afa79d8c-b9bc-4af7-84b8-d7d49e31d59e"",
                    ""expectedControlLayout"": """",
                    ""continuous"": false,
                    ""passThrough"": false,
                    ""initialStateCheck"": false,
                    ""processors"": """",
                    ""interactions"": """",
                    ""bindings"": []
                },
                {
                    ""name"": ""Skill1"",
                    ""id"": ""3d39d5e4-aa51-49ad-bb92-071060061403"",
                    ""expectedControlLayout"": """",
                    ""continuous"": false,
                    ""passThrough"": false,
                    ""initialStateCheck"": false,
                    ""processors"": """",
                    ""interactions"": """",
                    ""bindings"": []
                },
                {
                    ""name"": ""Skill2"",
                    ""id"": ""b1e3df68-b226-412f-a8b9-f0aa5ad60d59"",
                    ""expectedControlLayout"": """",
                    ""continuous"": false,
                    ""passThrough"": false,
                    ""initialStateCheck"": false,
                    ""processors"": """",
                    ""interactions"": """",
                    ""bindings"": []
                },
                {
                    ""name"": ""Skill3"",
                    ""id"": ""728e8880-8695-4ff1-afa7-4e6724b43f3e"",
                    ""expectedControlLayout"": """",
                    ""continuous"": false,
                    ""passThrough"": false,
                    ""initialStateCheck"": false,
                    ""processors"": """",
                    ""interactions"": """",
                    ""bindings"": []
                },
                {
                    ""name"": ""Skill4"",
                    ""id"": ""1a6a92d6-7f38-484f-8e0f-be42ee6fc5e6"",
                    ""expectedControlLayout"": """",
                    ""continuous"": false,
                    ""passThrough"": false,
                    ""initialStateCheck"": false,
                    ""processors"": """",
                    ""interactions"": """",
                    ""bindings"": []
                }
            ],
            ""bindings"": [
                {
                    ""name"": ""2D Vector"",
                    ""id"": ""775ab44c-59b4-4915-8465-f81c41de1422"",
                    ""path"": ""2DVector"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Movement"",
                    ""isComposite"": true,
                    ""isPartOfComposite"": false,
                    ""modifiers"": """"
                },
                {
                    ""name"": ""Up"",
                    ""id"": ""482afcdf-3a34-4c84-93fe-4ad76a16e626"",
                    ""path"": ""<Keyboard>/w"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Movement"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true,
                    ""modifiers"": """"
                },
                {
                    ""name"": ""Down"",
                    ""id"": ""17ea34a1-e700-4f1c-a8e0-e1e6ef1c63c3"",
                    ""path"": ""<Keyboard>/s"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Movement"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true,
                    ""modifiers"": """"
                },
                {
                    ""name"": ""Left"",
                    ""id"": ""e14bdae9-cf0f-4a26-8de9-150711b8ca12"",
                    ""path"": ""<Keyboard>/a"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Movement"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true,
                    ""modifiers"": """"
                },
                {
                    ""name"": ""Right"",
                    ""id"": ""1f8f2d09-16bd-4ce7-b038-c148f134e277"",
                    ""path"": ""<Keyboard>/d"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Movement"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true,
                    ""modifiers"": """"
                },
                {
                    ""name"": """",
                    ""id"": ""af096599-e7fa-43d8-b55a-a1730f693e22"",
                    ""path"": ""<Gamepad>/leftStick"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Movement"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false,
                    ""modifiers"": """"
                },
                {
                    ""name"": """",
                    ""id"": ""16df4172-8a8a-4687-ae54-ece6b089001a"",
                    ""path"": ""<Keyboard>/k"",
                    ""interactions"": ""Press"",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Jump"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false,
                    ""modifiers"": """"
                },
                {
                    ""name"": """",
                    ""id"": ""be09d691-4f73-4789-ae3a-fbdcf1f9b97c"",
                    ""path"": ""<Gamepad>/buttonSouth"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Jump"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false,
                    ""modifiers"": """"
                },
                {
                    ""name"": """",
                    ""id"": ""bf27698e-f7a8-4b21-a21d-778688e85cbd"",
                    ""path"": ""<Keyboard>/l"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Climb"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false,
                    ""modifiers"": """"
                },
                {
                    ""name"": """",
                    ""id"": ""dec8ffdb-2dcf-4f0d-af74-f8e23242f28e"",
                    ""path"": ""<Keyboard>/j"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Skill1"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false,
                    ""modifiers"": """"
                },
                {
                    ""name"": """",
                    ""id"": ""46d75f78-6ea5-4891-bd4d-94acec5eed30"",
                    ""path"": ""<Gamepad>/buttonWest"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Skill1"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false,
                    ""modifiers"": """"
                },
                {
                    ""name"": """",
                    ""id"": ""b41b84c9-73dd-40c6-a255-6dfb8ba531a9"",
                    ""path"": ""<Keyboard>/i"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Skill2"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false,
                    ""modifiers"": """"
                },
                {
                    ""name"": """",
                    ""id"": ""1d289bee-b3b8-4df8-a565-8a0b5a7f0bbf"",
                    ""path"": ""<Gamepad>/buttonNorth"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Skill2"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false,
                    ""modifiers"": """"
                },
                {
                    ""name"": """",
                    ""id"": ""2d760cc8-cbff-4edf-bd57-87f40bcdde31"",
                    ""path"": ""<Keyboard>/o"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Skill3"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false,
                    ""modifiers"": """"
                },
                {
                    ""name"": """",
                    ""id"": ""5eee2030-f53f-40fe-bc36-6aba0e911c08"",
                    ""path"": ""<Keyboard>/p"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Skill4"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false,
                    ""modifiers"": """"
                }
            ]
        },
        {
            ""name"": ""Actions"",
            ""id"": ""979648fe-b14b-49a0-88a0-f265d902f365"",
            ""actions"": [
                {
                    ""name"": ""Accept"",
                    ""id"": ""65446e76-5303-445e-9a14-aa3d76f04e8c"",
                    ""expectedControlLayout"": """",
                    ""continuous"": false,
                    ""passThrough"": false,
                    ""initialStateCheck"": false,
                    ""processors"": """",
                    ""interactions"": """",
                    ""bindings"": []
                },
                {
                    ""name"": ""Back"",
                    ""id"": ""24aa8211-93cc-4d8c-895f-850829cb1c26"",
                    ""expectedControlLayout"": """",
                    ""continuous"": false,
                    ""passThrough"": false,
                    ""initialStateCheck"": false,
                    ""processors"": """",
                    ""interactions"": """",
                    ""bindings"": []
                },
                {
                    ""name"": ""Interact"",
                    ""id"": ""2d4bb328-46c7-4bd7-bab7-da0d5569037d"",
                    ""expectedControlLayout"": """",
                    ""continuous"": false,
                    ""passThrough"": false,
                    ""initialStateCheck"": false,
                    ""processors"": """",
                    ""interactions"": ""Press"",
                    ""bindings"": []
                },
                {
                    ""name"": ""Inventory"",
                    ""id"": ""64ff6447-e02d-4e4e-9652-5340597bf192"",
                    ""expectedControlLayout"": """",
                    ""continuous"": false,
                    ""passThrough"": false,
                    ""initialStateCheck"": false,
                    ""processors"": """",
                    ""interactions"": ""Press"",
                    ""bindings"": []
                },
                {
                    ""name"": ""AnyKey"",
                    ""id"": ""b3a34c68-9479-44eb-bdec-4e10285db884"",
                    ""expectedControlLayout"": """",
                    ""continuous"": false,
                    ""passThrough"": false,
                    ""initialStateCheck"": false,
                    ""processors"": """",
                    ""interactions"": """",
                    ""bindings"": []
                },
                {
                    ""name"": ""Test"",
                    ""id"": ""f0b2ee71-4669-4ffb-b850-1d10eab9466f"",
                    ""expectedControlLayout"": """",
                    ""continuous"": false,
                    ""passThrough"": false,
                    ""initialStateCheck"": false,
                    ""processors"": """",
                    ""interactions"": """",
                    ""bindings"": []
                },
                {
                    ""name"": ""Touch"",
                    ""id"": ""6e192c60-8edc-4d0f-b132-807bbb64e9cf"",
                    ""expectedControlLayout"": """",
                    ""continuous"": true,
                    ""passThrough"": false,
                    ""initialStateCheck"": false,
                    ""processors"": """",
                    ""interactions"": """",
                    ""bindings"": []
                }
            ],
            ""bindings"": [
                {
                    ""name"": """",
                    ""id"": ""27722904-56eb-44f2-aa32-400b67f42bcd"",
                    ""path"": ""<Keyboard>/enter"",
                    ""interactions"": ""Press"",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Accept"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false,
                    ""modifiers"": """"
                },
                {
                    ""name"": """",
                    ""id"": ""8ca9675d-8f42-4b26-8ed6-4a77338a6684"",
                    ""path"": ""<Touchscreen>/button"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Accept"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false,
                    ""modifiers"": """"
                },
                {
                    ""name"": """",
                    ""id"": ""f6fa5300-e3df-4fb8-b39a-476ede7f5a51"",
                    ""path"": ""<Gamepad>/buttonSouth"",
                    ""interactions"": ""Press"",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Accept"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false,
                    ""modifiers"": """"
                },
                {
                    ""name"": """",
                    ""id"": ""a8727260-5d3d-4884-82c1-489bb4949d32"",
                    ""path"": ""<Keyboard>/escape"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Back"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false,
                    ""modifiers"": """"
                },
                {
                    ""name"": """",
                    ""id"": ""d2f67e44-5613-4262-9da1-b8f3cd7d8c1d"",
                    ""path"": ""<Keyboard>/e"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Interact"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false,
                    ""modifiers"": """"
                },
                {
                    ""name"": """",
                    ""id"": ""5a42a660-86c3-4aa6-b37a-ad917b97dc0a"",
                    ""path"": ""<Keyboard>/b"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Inventory"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false,
                    ""modifiers"": """"
                },
                {
                    ""name"": """",
                    ""id"": ""dc0d7f84-84ed-410e-8b16-358465e149ab"",
                    ""path"": ""<Keyboard>/anyKey"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""AnyKey"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false,
                    ""modifiers"": """"
                },
                {
                    ""name"": """",
                    ""id"": ""c1246c6a-cbc1-4e94-b043-69c762ce1578"",
                    ""path"": ""<Keyboard>/enter"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""AnyKey"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false,
                    ""modifiers"": """"
                },
                {
                    ""name"": """",
                    ""id"": ""1c02bf98-5986-42e1-ae0c-5a9b579966e2"",
                    ""path"": ""<Touchscreen>/phase"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Test"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false,
                    ""modifiers"": """"
                },
                {
                    ""name"": """",
                    ""id"": ""ed36431a-f2ab-461d-98c2-21aaadcbaa33"",
                    ""path"": ""<Touchscreen>/touch"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Test"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false,
                    ""modifiers"": """"
                },
                {
                    ""name"": """",
                    ""id"": ""bd2b07b1-24f5-4ab8-ad38-f1e07a9f128b"",
                    ""path"": ""<Touchscreen>/position"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Touch"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false,
                    ""modifiers"": """"
                },
                {
                    ""name"": """",
                    ""id"": ""cc4ca2cc-7979-4fdc-9176-0e63117d8010"",
                    ""path"": ""<Mouse>/position"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Touch"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false,
                    ""modifiers"": """"
                }
            ]
        }
    ],
    ""controlSchemes"": []
}");
        // GamePlay
        m_GamePlay = asset.GetActionMap("GamePlay");
        m_GamePlay_Movement = m_GamePlay.GetAction("Movement");
        m_GamePlay_Jump = m_GamePlay.GetAction("Jump");
        m_GamePlay_Climb = m_GamePlay.GetAction("Climb");
        m_GamePlay_Skill1 = m_GamePlay.GetAction("Skill1");
        m_GamePlay_Skill2 = m_GamePlay.GetAction("Skill2");
        m_GamePlay_Skill3 = m_GamePlay.GetAction("Skill3");
        m_GamePlay_Skill4 = m_GamePlay.GetAction("Skill4");
        // Actions
        m_Actions = asset.GetActionMap("Actions");
        m_Actions_Accept = m_Actions.GetAction("Accept");
        m_Actions_Back = m_Actions.GetAction("Back");
        m_Actions_Interact = m_Actions.GetAction("Interact");
        m_Actions_Inventory = m_Actions.GetAction("Inventory");
        m_Actions_AnyKey = m_Actions.GetAction("AnyKey");
        m_Actions_Test = m_Actions.GetAction("Test");
        m_Actions_Touch = m_Actions.GetAction("Touch");
    }

    ~MAJIKAInput()
    {
        UnityEngine.Object.Destroy(asset);
    }

    public InputBinding? bindingMask
    {
        get => asset.bindingMask;
        set => asset.bindingMask = value;
    }

    public ReadOnlyArray<InputDevice>? devices
    {
        get => asset.devices;
        set => asset.devices = value;
    }

    public ReadOnlyArray<InputControlScheme> controlSchemes
    {
        get => asset.controlSchemes;
    }

    public bool Contains(InputAction action)
    {
        return asset.Contains(action);
    }

    public IEnumerator<InputAction> GetEnumerator()
    {
        return asset.GetEnumerator();
    }

    IEnumerator IEnumerable.GetEnumerator()
    {
        return GetEnumerator();
    }

    public void Enable()
    {
        asset.Enable();
    }

    public void Disable()
    {
        asset.Disable();
    }

    // GamePlay
    private InputActionMap m_GamePlay;
    private IGamePlayActions m_GamePlayActionsCallbackInterface;
    private InputAction m_GamePlay_Movement;
    private InputAction m_GamePlay_Jump;
    private InputAction m_GamePlay_Climb;
    private InputAction m_GamePlay_Skill1;
    private InputAction m_GamePlay_Skill2;
    private InputAction m_GamePlay_Skill3;
    private InputAction m_GamePlay_Skill4;
    public struct GamePlayActions
    {
        private MAJIKAInput m_Wrapper;
        public GamePlayActions(MAJIKAInput wrapper) { m_Wrapper = wrapper; }
        public InputAction @Movement { get { return m_Wrapper.m_GamePlay_Movement; } }
        public InputAction @Jump { get { return m_Wrapper.m_GamePlay_Jump; } }
        public InputAction @Climb { get { return m_Wrapper.m_GamePlay_Climb; } }
        public InputAction @Skill1 { get { return m_Wrapper.m_GamePlay_Skill1; } }
        public InputAction @Skill2 { get { return m_Wrapper.m_GamePlay_Skill2; } }
        public InputAction @Skill3 { get { return m_Wrapper.m_GamePlay_Skill3; } }
        public InputAction @Skill4 { get { return m_Wrapper.m_GamePlay_Skill4; } }
        public InputActionMap Get() { return m_Wrapper.m_GamePlay; }
        public void Enable() { Get().Enable(); }
        public void Disable() { Get().Disable(); }
        public bool enabled { get { return Get().enabled; } }
        public InputActionMap Clone() { return Get().Clone(); }
        public static implicit operator InputActionMap(GamePlayActions set) { return set.Get(); }
        public void SetCallbacks(IGamePlayActions instance)
        {
            if (m_Wrapper.m_GamePlayActionsCallbackInterface != null)
            {
                Movement.started -= m_Wrapper.m_GamePlayActionsCallbackInterface.OnMovement;
                Movement.performed -= m_Wrapper.m_GamePlayActionsCallbackInterface.OnMovement;
                Movement.canceled -= m_Wrapper.m_GamePlayActionsCallbackInterface.OnMovement;
                Jump.started -= m_Wrapper.m_GamePlayActionsCallbackInterface.OnJump;
                Jump.performed -= m_Wrapper.m_GamePlayActionsCallbackInterface.OnJump;
                Jump.canceled -= m_Wrapper.m_GamePlayActionsCallbackInterface.OnJump;
                Climb.started -= m_Wrapper.m_GamePlayActionsCallbackInterface.OnClimb;
                Climb.performed -= m_Wrapper.m_GamePlayActionsCallbackInterface.OnClimb;
                Climb.canceled -= m_Wrapper.m_GamePlayActionsCallbackInterface.OnClimb;
                Skill1.started -= m_Wrapper.m_GamePlayActionsCallbackInterface.OnSkill1;
                Skill1.performed -= m_Wrapper.m_GamePlayActionsCallbackInterface.OnSkill1;
                Skill1.canceled -= m_Wrapper.m_GamePlayActionsCallbackInterface.OnSkill1;
                Skill2.started -= m_Wrapper.m_GamePlayActionsCallbackInterface.OnSkill2;
                Skill2.performed -= m_Wrapper.m_GamePlayActionsCallbackInterface.OnSkill2;
                Skill2.canceled -= m_Wrapper.m_GamePlayActionsCallbackInterface.OnSkill2;
                Skill3.started -= m_Wrapper.m_GamePlayActionsCallbackInterface.OnSkill3;
                Skill3.performed -= m_Wrapper.m_GamePlayActionsCallbackInterface.OnSkill3;
                Skill3.canceled -= m_Wrapper.m_GamePlayActionsCallbackInterface.OnSkill3;
                Skill4.started -= m_Wrapper.m_GamePlayActionsCallbackInterface.OnSkill4;
                Skill4.performed -= m_Wrapper.m_GamePlayActionsCallbackInterface.OnSkill4;
                Skill4.canceled -= m_Wrapper.m_GamePlayActionsCallbackInterface.OnSkill4;
            }
            m_Wrapper.m_GamePlayActionsCallbackInterface = instance;
            if (instance != null)
            {
                Movement.started += instance.OnMovement;
                Movement.performed += instance.OnMovement;
                Movement.canceled += instance.OnMovement;
                Jump.started += instance.OnJump;
                Jump.performed += instance.OnJump;
                Jump.canceled += instance.OnJump;
                Climb.started += instance.OnClimb;
                Climb.performed += instance.OnClimb;
                Climb.canceled += instance.OnClimb;
                Skill1.started += instance.OnSkill1;
                Skill1.performed += instance.OnSkill1;
                Skill1.canceled += instance.OnSkill1;
                Skill2.started += instance.OnSkill2;
                Skill2.performed += instance.OnSkill2;
                Skill2.canceled += instance.OnSkill2;
                Skill3.started += instance.OnSkill3;
                Skill3.performed += instance.OnSkill3;
                Skill3.canceled += instance.OnSkill3;
                Skill4.started += instance.OnSkill4;
                Skill4.performed += instance.OnSkill4;
                Skill4.canceled += instance.OnSkill4;
            }
        }
    }
    public GamePlayActions @GamePlay
    {
        get
        {
            return new GamePlayActions(this);
        }
    }

    // Actions
    private InputActionMap m_Actions;
    private IActionsActions m_ActionsActionsCallbackInterface;
    private InputAction m_Actions_Accept;
    private InputAction m_Actions_Back;
    private InputAction m_Actions_Interact;
    private InputAction m_Actions_Inventory;
    private InputAction m_Actions_AnyKey;
    private InputAction m_Actions_Test;
    private InputAction m_Actions_Touch;
    public struct ActionsActions
    {
        private MAJIKAInput m_Wrapper;
        public ActionsActions(MAJIKAInput wrapper) { m_Wrapper = wrapper; }
        public InputAction @Accept { get { return m_Wrapper.m_Actions_Accept; } }
        public InputAction @Back { get { return m_Wrapper.m_Actions_Back; } }
        public InputAction @Interact { get { return m_Wrapper.m_Actions_Interact; } }
        public InputAction @Inventory { get { return m_Wrapper.m_Actions_Inventory; } }
        public InputAction @AnyKey { get { return m_Wrapper.m_Actions_AnyKey; } }
        public InputAction @Test { get { return m_Wrapper.m_Actions_Test; } }
        public InputAction @Touch { get { return m_Wrapper.m_Actions_Touch; } }
        public InputActionMap Get() { return m_Wrapper.m_Actions; }
        public void Enable() { Get().Enable(); }
        public void Disable() { Get().Disable(); }
        public bool enabled { get { return Get().enabled; } }
        public InputActionMap Clone() { return Get().Clone(); }
        public static implicit operator InputActionMap(ActionsActions set) { return set.Get(); }
        public void SetCallbacks(IActionsActions instance)
        {
            if (m_Wrapper.m_ActionsActionsCallbackInterface != null)
            {
                Accept.started -= m_Wrapper.m_ActionsActionsCallbackInterface.OnAccept;
                Accept.performed -= m_Wrapper.m_ActionsActionsCallbackInterface.OnAccept;
                Accept.canceled -= m_Wrapper.m_ActionsActionsCallbackInterface.OnAccept;
                Back.started -= m_Wrapper.m_ActionsActionsCallbackInterface.OnBack;
                Back.performed -= m_Wrapper.m_ActionsActionsCallbackInterface.OnBack;
                Back.canceled -= m_Wrapper.m_ActionsActionsCallbackInterface.OnBack;
                Interact.started -= m_Wrapper.m_ActionsActionsCallbackInterface.OnInteract;
                Interact.performed -= m_Wrapper.m_ActionsActionsCallbackInterface.OnInteract;
                Interact.canceled -= m_Wrapper.m_ActionsActionsCallbackInterface.OnInteract;
                Inventory.started -= m_Wrapper.m_ActionsActionsCallbackInterface.OnInventory;
                Inventory.performed -= m_Wrapper.m_ActionsActionsCallbackInterface.OnInventory;
                Inventory.canceled -= m_Wrapper.m_ActionsActionsCallbackInterface.OnInventory;
                AnyKey.started -= m_Wrapper.m_ActionsActionsCallbackInterface.OnAnyKey;
                AnyKey.performed -= m_Wrapper.m_ActionsActionsCallbackInterface.OnAnyKey;
                AnyKey.canceled -= m_Wrapper.m_ActionsActionsCallbackInterface.OnAnyKey;
                Test.started -= m_Wrapper.m_ActionsActionsCallbackInterface.OnTest;
                Test.performed -= m_Wrapper.m_ActionsActionsCallbackInterface.OnTest;
                Test.canceled -= m_Wrapper.m_ActionsActionsCallbackInterface.OnTest;
                Touch.started -= m_Wrapper.m_ActionsActionsCallbackInterface.OnTouch;
                Touch.performed -= m_Wrapper.m_ActionsActionsCallbackInterface.OnTouch;
                Touch.canceled -= m_Wrapper.m_ActionsActionsCallbackInterface.OnTouch;
            }
            m_Wrapper.m_ActionsActionsCallbackInterface = instance;
            if (instance != null)
            {
                Accept.started += instance.OnAccept;
                Accept.performed += instance.OnAccept;
                Accept.canceled += instance.OnAccept;
                Back.started += instance.OnBack;
                Back.performed += instance.OnBack;
                Back.canceled += instance.OnBack;
                Interact.started += instance.OnInteract;
                Interact.performed += instance.OnInteract;
                Interact.canceled += instance.OnInteract;
                Inventory.started += instance.OnInventory;
                Inventory.performed += instance.OnInventory;
                Inventory.canceled += instance.OnInventory;
                AnyKey.started += instance.OnAnyKey;
                AnyKey.performed += instance.OnAnyKey;
                AnyKey.canceled += instance.OnAnyKey;
                Test.started += instance.OnTest;
                Test.performed += instance.OnTest;
                Test.canceled += instance.OnTest;
                Touch.started += instance.OnTouch;
                Touch.performed += instance.OnTouch;
                Touch.canceled += instance.OnTouch;
            }
        }
    }
    public ActionsActions @Actions
    {
        get
        {
            return new ActionsActions(this);
        }
    }
    public interface IGamePlayActions
    {
        void OnMovement(InputAction.CallbackContext context);
        void OnJump(InputAction.CallbackContext context);
        void OnClimb(InputAction.CallbackContext context);
        void OnSkill1(InputAction.CallbackContext context);
        void OnSkill2(InputAction.CallbackContext context);
        void OnSkill3(InputAction.CallbackContext context);
        void OnSkill4(InputAction.CallbackContext context);
    }
    public interface IActionsActions
    {
        void OnAccept(InputAction.CallbackContext context);
        void OnBack(InputAction.CallbackContext context);
        void OnInteract(InputAction.CallbackContext context);
        void OnInventory(InputAction.CallbackContext context);
        void OnAnyKey(InputAction.CallbackContext context);
        void OnTest(InputAction.CallbackContext context);
        void OnTouch(InputAction.CallbackContext context);
    }
}
